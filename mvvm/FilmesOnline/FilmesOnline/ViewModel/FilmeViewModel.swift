//
//  FilmeViewModel.swift
//  FilmesOnlineMVVM
//
//  Created by SoSucesso on 13/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import Foundation

class FilmeViewModel {
    
    private static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    let filme: Filme
    
    let titulo: String
    let dataLancamentoTexto: String
    // detalhes:
    let generosTexto: String
    let sinopse: String
    
    init(filme: Filme) {
        self.filme = filme
        
        titulo = filme.titulo
        if let data = filme.dataLancamento {
            dataLancamentoTexto = FilmeViewModel.dateFormatter.string(from: data)
        } else {
            dataLancamentoTexto = "-"
        }
        if let generos = filme.generos, generos.count > 0 {
            let texto = generos.map({ (genero) -> String in
                genero.nome
            }).joined(separator: " , ")
            generosTexto = texto
        } else {
            generosTexto = "-"
        }
        sinopse = filme.sinopse.isEmpty ? "-" : filme.sinopse
    }
    
}
