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
    private let mainViewModel = MainViewModel()
    private var filmes: [FilmeViewModel] = []
    
    // MARK: outlets
    @IBOutlet weak var viewErro: UIView!
    @IBOutlet weak var labelErro: UILabel!
    @IBOutlet weak var viewCarregando: UIView!
    @IBOutlet weak var tableFilmes: UITableView!
    
    // MARK: actions:
    
    @IBAction func touchTentarNovamente(_ sender: Any) {
        mainViewModel.carregarFilmes()
    }
    
    // MARK: ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableFilmes.dataSource = self
        tableFilmes.register(UINib(nibName: "FilmeCell", bundle: nil), forCellReuseIdentifier: "FilmeCell")
        tableFilmes.delegate = self
        
        setup()
    }
    
    private func setup() {
        _ = mainViewModel.getCarregando().subscribe { (event) in self.viewCarregando.isHidden = !(event.element ?? false)  }
        _ = mainViewModel.getErro().subscribe { (event) in
            if let element = event.element, let erro = element {
                self.labelErro.text = erro
                self.viewErro.isHidden = false
            } else {
                self.viewErro.isHidden = true
            }
        }
        _ = mainViewModel.getFilmes().subscribe { (event) in
            self.filmes = event.element ?? []
            self.tableFilmes.reloadData()
        }
        _ = mainViewModel.getDetalhes().subscribe { (event) in
            if let detalhe = event.element {
                self.performSegue(withIdentifier: "detalharFilme", sender: detalhe)
            }
        }
        
        mainViewModel.carregarFilmes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController,
            let filme = sender as? FilmeViewModel {
            detalheVC.filmeViewModel = filme
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
        cell.labelData.text = filme.dataLancamentoTexto
        
        return cell
    }
    
}

// MARK: UITableViewDelegate

extension MainViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= filmes.count - 1 {
            mainViewModel.carregarFilmes()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filme = filmes[indexPath.row]
        mainViewModel.carregarDetalhes(filme)
    }
}

