//
//  DetalheViewModel.swift
//  FilmesOnlineMVVM
//
//  Created by SoSucesso on 13/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class DetalheViewModel  {
    
    private let carregando = BehaviorRelay<Bool>(value: false)
    private let imagemPoster = BehaviorRelay<UIImage?>(value: nil)
    private var posterCarregado = false
    
    func getCarregando() -> Observable<Bool> { return carregando.asObservable() }
    func getImagemPoster() -> Observable<UIImage?> { return imagemPoster.asObservable() }
    
    func carregarPoster(_ filmeViewModel: FilmeViewModel) {
        if carregando.value || posterCarregado {
            return
        }
        
        carregando.accept(true)
        
        MovieDB.instance.carregarPoster(filme: filmeViewModel.filme) { [weak self] (image) in
            guard let this = self else {
                return
            }
            
            this.carregando.accept(false)
            if let img = image {
                this.imagemPoster.accept(img)
                this.posterCarregado = true
            } else {
                this.imagemPoster.accept(UIImage(named: "ic_error"))
                this.posterCarregado = false
            }
        }
    }
}
