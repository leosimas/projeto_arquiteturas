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
import UIKit
import AlamofireImage

class MovieDB {
    
    static let instance = MovieDB()
    
    private let API_KEY = "1f54bd990f1cdfb230adb312546d765d"
    private let API_URL = "https://api.themoviedb.org/3/"
    private let API_IMG_URL = "https://image.tmdb.org/t/p/"
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
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
            parameters["query"] = termoPesquisa
        }
        
        guard let url = URL(string: stringUrl) else {
            completion(nil, "Erro na requisição")
            return
        }
        
        AF.request(url, method: .get, parameters: parameters)
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
    
    func detalharFilme(_ filme: Filme, completion: @escaping (Filme?, String?) -> Void) {
        let stringUrl = "\(API_URL)movie/\(filme.id)"
        guard let url = URL(string: stringUrl) else {
            completion(nil, "Erro na requisição")
            return
        }
        
        AF.request(url, method: .get, parameters: criarQueryDic())
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
                    
                    let filme = this.criarFilme(json)
                    completion(filme, nil)
                case .failure(let error):
                    completion(nil, "Erro na requisição : \(error.localizedDescription)")
                }
        }
    }
    
    func carregarPoster(filme: Filme, completion: @escaping (Image?) -> Void) {
        guard let path = filme.pathPoster else {
            completion(nil)
            return
        }
        let urlImagem = "\(API_IMG_URL)w300\(path)"
        AF.request(urlImagem).responseImage { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure( _):
                completion(nil)
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
            let filme = criarFilme(json)
            filmes.append(filme)
        }
        
        return filmes
    }
    
    private func criarFilme(_ json: JSON) -> Filme {
        let filme = Filme()
        filme.id = json["id"].intValue
        filme.titulo = json["title"].stringValue
        filme.sinopse = json["overview"].stringValue
        filme.dataLancamento = dateFormatter.date(from: json["release_date"].stringValue)
        
        if let jsonGenres = json["genres"].array {
            var generos: [Genero] = []
            jsonGenres.forEach { (jsonGen) in
                let g = Genero()
                g.id = jsonGen["id"].intValue
                g.nome = jsonGen["name"].stringValue
                generos.append(g)
            }
            filme.generos = generos
        }
        
        if let homepage = json["homepage"].string {
            filme.urlSite = homepage
        }
        
        if let poster = json["poster_path"].string {
            filme.pathPoster = poster
        }
        
        return filme
    }
    
}
