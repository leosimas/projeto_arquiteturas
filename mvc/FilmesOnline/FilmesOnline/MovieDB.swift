//
//  MovieDB.swift
//  FilmesOnline
//
//  Created by ssa on 11/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class MovieDB {
    
    static let instance = MovieDB()
    
    private let API_KEY = "1f54bd990f1cdfb230adb312546d765d"
    private let API_URL = "https://api.themoviedb.org/3/"
    
    private init() {}

    private func criarQueryDic() -> [String:String] {
        var query:[String:String] = [:]
        query["api_key"] = API_KEY
        query["language"] = "pt-BR"
        return query
    }
    
    func listarFilmes(pagina : Int, termoPesquisa : String? = nil, completion: @escaping (Pagina?, String?) -> Void) {
        
        var parameters = criarQueryDic()
        parameters["page"] = "\(pagina)"

        var stringUrl = "\(API_URL)"
        if termoPesquisa == nil {
            stringUrl.append("movie/upcoming")
        } else {
            stringUrl.append("search/movie")
            //parameters["query"] = termoPesquisa
        }
        
        guard let url = URL(string: stringUrl) else {
            completion(nil, "Erro na requisição")
            return
        }
        
        AF.request(url, method: .get, parameters: parameters)
            //.validate(statusCode: 200...299)
            .responseJSON { [weak self] response in
                guard let this = self else {
                    return
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let erro = json["errors"].array?[0].string {
                        completion(nil, erro)
                        return
                    }
                    
                    let pagina = this.criarPagina(json)
                    completion(pagina, nil)
                case .failure(let error):
                    completion(nil, "Erro na requisição : \(error.localizedDescription)")
                }
        }
        
    }
    
    private func criarPagina(_ json: JSON) -> Pagina {
        let pagina = Pagina()
        pagina.numero = json["page"].intValue
        pagina.total = json["total_pages"].intValue
        pagina.filmes = criarFilmes(json["results"].arrayValue)
        return pagina
    }
    
    private func criarFilmes(_ jsonArray: [JSON]) -> [Filme] {
        var filmes: [Filme] = []
        
        jsonArray.forEach { (json) in
            let filme = Filme()
            filme.titulo = json["title"].stringValue
            filme.sinopse = json["overview"].stringValue
            filme.dataLancamento = json["release_date"].stringValue
            
            filmes.append(filme)
        }
        
        return filmes
    }
    
}
