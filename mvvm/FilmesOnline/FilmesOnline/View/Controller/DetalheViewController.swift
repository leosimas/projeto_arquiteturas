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
    
    var filmeViewModel: FilmeViewModel!
    private var detalheViewModel = DetalheViewModel()
    
    // MARK: outlets
    
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var labelGeneros: UILabel!
    @IBOutlet weak var labelSinopse: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // MARK: actions
    
    @objc func toqueImagePoster() {
        detalheViewModel.carregarPoster(filmeViewModel)
    }
    
    // MARK: ciclo
    
    override func viewDidLoad() {
        setup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toqueImagePoster))
        imagePoster.addGestureRecognizer(tapGesture)
    }
    
    private func setup() {
        exibirFilme()
        
        _ = detalheViewModel.getCarregando().subscribe { (event) in
            let carregando = event.element ?? false
            self.indicatorView.isHidden = !carregando
            if carregando {
                self.indicatorView.startAnimating()
            } else {
                self.indicatorView.stopAnimating()
            }
        }
        _ = detalheViewModel.getImagemPoster().subscribe { (event) in
            if let image = event.element {
                self.imagePoster.image = image
            }
        }
        
        detalheViewModel.carregarPoster(filmeViewModel)
    }
    
    // MARK: controle
    
    private func exibirFilme() {
        labelTitulo.text = filmeViewModel.titulo
        labelSinopse.text = filmeViewModel.sinopse
        labelGeneros.text = filmeViewModel.generosTexto
    }
    
}
