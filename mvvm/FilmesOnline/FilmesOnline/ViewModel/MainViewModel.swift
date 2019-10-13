//
//  MainViewModel.swift
//  FilmesOnlineMVVM
//
//  Created by SoSucesso on 13/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay


class MainViewModel {
    
    private var paginaAtual: Pagina? = nil
    private var filmes: [Filme] = []
    private let filmeViewModels = PublishRelay<[FilmeViewModel]>()
    private let carregando = BehaviorRelay<Bool>(value: false)
    private let erro = BehaviorRelay<String?>(value: nil)
    private let filmeDetalhado = PublishRelay<FilmeViewModel>()
    
    func getFilmes() -> Observable<[FilmeViewModel]> { return filmeViewModels.asObservable() }
    func getCarregando() -> Observable<Bool> { return carregando.asObservable() }
    func getErro() -> Observable<String?> { return erro.asObservable() }
    func getDetalhes() -> Observable<FilmeViewModel> { return filmeDetalhado.asObservable() }
    
    // MARK: formatacao
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    func carregarFilmes() {
        if carregando.value {
            return
        }
        
        if let p = paginaAtual, p.total == p.numero {
            return
        }
        
        carregando.accept(true)
        erro.accept(nil)
        
        let proximaPagina = (paginaAtual?.numero ?? 0) + 1
        if proximaPagina == 1 {
            filmes.removeAll()
        }
        
        MovieDB.instance.listarFilmes(pagina: proximaPagina) { [weak self] (pagina, mensagemErro) in
            guard let this = self else {
                return
            }
            
            this.carregando.accept(false)
            
            guard let pag = pagina else {
                if let msg = mensagemErro {
                    this.erro.accept(msg)
                }
                return
            }
            
            this.paginaAtual = pag
            this.filmes.append(contentsOf: pag.filmes)
            var viewModels: [FilmeViewModel] = []
            this.filmes.forEach({ (f) in
                viewModels.append(FilmeViewModel(filme: f))
            })
            this.filmeViewModels.accept(viewModels)
        }
    }
    
    func carregarDetalhes(_ filmeViewModel: FilmeViewModel) {
        if carregando.value {
            return
        }
        
        carregando.accept(true)
        
        MovieDB.instance.detalharFilme(filmeViewModel.filme) { [weak self]  (filmeDetalhado, mensagemErro) in
            guard let this = self else {
                return
            }
            
            this.carregando.accept(false)
            
            guard let detalhe = filmeDetalhado else {
                if let msg = mensagemErro {
                    this.erro.accept(msg)
                }
                return
            }
            
            this.filmeDetalhado.accept(FilmeViewModel(filme: detalhe))
        }
    }
    
    
}
