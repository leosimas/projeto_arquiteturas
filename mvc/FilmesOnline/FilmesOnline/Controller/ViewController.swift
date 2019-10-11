//
//  ViewController.swift
//  FilmesOnline
//
//  Created by SoSucesso on 10/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        MovieDB.instance.listarFilmes(pagina: 1) { (pagina, mensagemErro) in
            guard let pag = pagina else {
                if let erro = mensagemErro {
                    print(erro)
                }
                return
            }
            
            print(pag)
        }
    }


}

