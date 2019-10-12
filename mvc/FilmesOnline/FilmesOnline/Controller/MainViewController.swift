//
//  MainViewController.swift
//  FilmesOnline
//
//  Created by SoSucesso on 10/10/19.
//  Copyright © 2019 Leonardo Simas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: estado
    private var paginaAtual: Pagina? = nil
    private var filmes: [Filme] = []
    private var estaCarregando = false
    
    // MARK: formatacao
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    // MARK: outlets
    @IBOutlet weak var viewErro: UIView!
    @IBOutlet weak var labelErro: UILabel!
    @IBOutlet weak var viewCarregando: UIView!
    @IBOutlet weak var tableFilmes: UITableView!
    
    // MARK: actions:
    
    @IBAction func touchTentarNovamente(_ sender: Any) {
        carregarFilmes()
    }
    
    // MARK: ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableFilmes.dataSource = self
        tableFilmes.register(UINib(nibName: "FilmeCell", bundle: nil), forCellReuseIdentifier: "FilmeCell")
        tableFilmes.delegate = self
        
        carregarFilmes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController,
            let filme = sender as? Filme {
            detalheVC.filme = filme
        }
    }
    
    // MARK: controle
    
    private func exibirCarregando(_ carregando: Bool) {
        estaCarregando = carregando
        viewCarregando.isHidden = !carregando
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
        if estaCarregando {
            return
        }
        if let p = paginaAtual, p.total == p.numero {
            return
        }
        
        exibirCarregando(true)
        exibirErro(nil)
        
        let proximaPagina = (paginaAtual?.numero ?? 0) + 1
        if proximaPagina == 1 {
            filmes.removeAll()
        }
        
        MovieDB.instance.listarFilmes(pagina: proximaPagina) { [weak self] (pagina, mensagemErro) in
            
            guard let this = self else {
                return
            }
            
            this.exibirCarregando(false)
            
            guard let pag = pagina else {
                if let erro = mensagemErro {
                    this.exibirErro(erro)
                }
                return
            }
            
            this.paginaAtual = pag
            this.exibirFilmes(pag.filmes)
        }
    }
    
    private func carregarDetalhes(_ filme: Filme) {
        if estaCarregando {
            return
        }
        if let p = paginaAtual, p.total == p.numero {
            return
        }
        
        exibirCarregando(true)
        
        MovieDB.instance.detalharFilme(filme) { [weak self]  (filmeDetalhado, mensagemErro) in
            guard let this = self else {
                return
            }
            
            this.exibirCarregando(false)
            
            guard let detalhe = filmeDetalhado else {
                if let erro = mensagemErro {
                    this.exibirErro(erro)
                }
                return
            }
            
            this.performSegue(withIdentifier: "detalharFilme", sender: detalhe)
        }
    }

}

// MARK: UITableViewDataSource

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filme = filmes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmeCell") as! FilmeCell
        cell.labelTitulo.text = filme.titulo
        if let data = filme.dataLancamento {
            cell.labelData.text = dateFormatter.string(from: data)
        } else {
            cell.labelData.text = "-"
        }
        
        return cell
    }
    
}

// MARK: UITableViewDelegate

extension MainViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= filmes.count - 1 {
            carregarFilmes()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filme = filmes[indexPath.row]
        carregarDetalhes(filme)
    }
}

