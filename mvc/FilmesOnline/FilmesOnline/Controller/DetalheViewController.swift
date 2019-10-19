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
    // MARK: estado
    private var carregandoPoster = false
    private var posterCarregado = false
    
    // MARK: outlets
    
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var labelGeneros: UILabel!
    @IBOutlet weak var labelSinopse: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: actions
    
    @objc func toqueImagePoster() {
        if carregandoPoster || posterCarregado {
            return
        }
        
        carregarPoster()
    }
    
    // MARK: ciclo
    
    override func viewDidLoad() {
        exibirFilme()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toqueImagePoster))
        imagePoster.addGestureRecognizer(tapGesture)
    }
    
    // MARK: controle
    
    private func exibirFilme() {
        labelTitulo.text = filme.titulo
        if filme.sinopse.isEmpty {
            labelSinopse.text = "-"
        } else {
            labelSinopse.text = filme.sinopse
        }
        
        let qtde = filme.generos?.count ?? 0
        if qtde == 0 {
            labelGeneros.text = "-"
        } else if let generos = filme.generos {
            let texto = generos.map({ (genero) -> String in
                genero.nome
            }).joined(separator: " , ")
            labelGeneros.text = texto
        }
        
        carregarPoster()
    }
    
    private func carregarPoster() {
        exibirCarregandoPoster(true)
        
        MovieDB.instance.carregarPoster(filme: filme) { [weak self] (image) in
            guard let this = self else {
                return
            }
            
            this.exibirCarregandoPoster(false)
            this.exibirPoster(image)
        }
    }
    
    private func exibirCarregandoPoster(_ carregando: Bool) {
        carregandoPoster = carregando
        indicatorView.isHidden = !carregando
        if carregando {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }
    }
    
    private func exibirPoster(_ image: UIImage?) {
        if let img = image {
            imagePoster.image = img
            posterCarregado = true
        } else {
            imagePoster.image = UIImage(named: "ic_error")
            posterCarregado = false
        }
    }
    
}
