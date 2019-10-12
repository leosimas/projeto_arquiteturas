//
//  DetalheViewController.swift
//  FilmesOnline
//
//  Created by SoSucesso on 12/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import Foundation
import UIKit

class DetalheViewController : UIViewController {
    
    var filme: Filme!
    
    // MARK: outlets
    
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var labelGeneros: UILabel!
    @IBOutlet weak var labelSinopse: UILabel!
    
    override func viewDidLoad() {
        labelTitulo.text = "\(filme.titulo)\n"
        labelSinopse.text = "\n\n\(filme.sinopse)"
        
        let qtde = filme.generos?.count ?? 0
        if qtde == 0 {
            labelGeneros.text = "-"
        } else if let generos = filme.generos {
            let texto = generos.map({ (genero) -> String in
                genero.nome
            }).joined(separator: " ,")
            labelGeneros.text = texto
        }
        
    }
    
}
