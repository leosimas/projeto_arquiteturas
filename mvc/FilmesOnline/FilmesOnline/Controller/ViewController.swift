//
//  ViewController.swift
//  FilmesOnline
//
//  Created by SoSucesso on 10/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: estado
    private var paginaAtual = 0
    private var filmes: [Filme] = []
    
    // MARK: outlets
    @IBOutlet weak var viewErro: UIView!
    @IBOutlet weak var labelErro: UILabel!
    @IBOutlet weak var viewCarregando: UIView!
    @IBOutlet weak var tableFilmes: UITableView!
    
    // MARK: actions:
    
    @IBAction func touchTentarNovamente(_ sender: Any) {
        carregarFilmes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableFilmes.dataSource = self
        tableFilmes.register(UINib(nibName: "FilmeCell", bundle: nil), forCellReuseIdentifier: "FilmeCell")
        
        carregarFilmes()
    }
    
    private func exibirFilmes(_ novosFilmes: [Filme]) {
        exibirErro(nil)
        filmes.append(contentsOf: novosFilmes)
        tableFilmes.reloadData()
    }
    
    private func exibirErro(_ mensagemErro: String?) {
        if let erro = mensagemErro {
            labelErro.text = erro
            viewErro.isHidden = false
        } else {
            viewErro.isHidden = true
        }
    }
    
    private func carregarFilmes() {
        viewCarregando.isHidden = false
        exibirErro(nil)
        
        let proximaPagina = paginaAtual + 1
        
        if proximaPagina == 1 {
            filmes.removeAll()
        }
        
        MovieDB.instance.listarFilmes(pagina: proximaPagina) { [weak self] (pagina, mensagemErro) in
            
            guard let this = self else {
                return
            }
            
            this.viewCarregando.isHidden = true
            
            guard let pag = pagina else {
                if let erro = mensagemErro {
                    this.exibirErro(erro)
                }
                return
            }
            
            this.paginaAtual = proximaPagina
            this.exibirFilmes(pag.filmes)
        }
    }

}

// MARK: UITableViewDataSource

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filme = filmes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmeCell") as! FilmeCell
        cell.labelTitulo.text = filme.titulo
        cell.labelData.text = filme.dataLancamento
        
        return cell
    }
    
}

