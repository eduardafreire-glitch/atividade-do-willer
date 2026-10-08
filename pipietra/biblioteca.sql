CREATE TABLE leitores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE livros (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    taxa_diaria DECIMAL(10,2) CHECK (taxa_diaria > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE emprestimos (
    id SERIAL PRIMARY KEY,
    leitor_id INT REFERENCES leitores(id),
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado'))
);

CREATE TABLE itens_emprestimo (
    id SERIAL PRIMARY KEY,
    emprestimo_id INT REFERENCES emprestimos(id),
    livro_id INT REFERENCES livros(id),
    quantidade INT CHECK (quantidade > 0) NOT NULL,
    valor_diaria DECIMAL(10,2) CHECK (valor_diaria >= 0) NOT NULL
);

INSERT INTO categorias (nome) VALUES ('Ficção'), ('História'), ('Tecnologia');

INSERT INTO livros (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES 
(1, 'O Senhor dos Anéis', '9780007525546', 7.50, TRUE),
(1, '1984', '9780451524935', 4.00, TRUE),
(3, 'Entendendo Algoritmos', '9788575225639', 6.00, TRUE);

INSERT INTO leitores (nome, email, cpf, telefone) VALUES 
('Lucas Martins', 'lucas@email.com', '11122233344', '11999990000'),
('Mariana Souza', 'mariana@email.com', '22233344455', '11988880000'),
('Gabriel Oliveira', 'gabriel@email.com', '33344455566', '11977770000');

INSERT INTO emprestimos (leitor_id, status) VALUES 
(1, 'Devolvido'), (1, 'Ativo'), (2, 'Devolvido'), (3, 'Atrasado');

INSERT INTO itens_emprestimo (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES 
(1, 1, 2, 7.50),
(2, 2, 1, 4.00),
(3, 3, 3, 6.00),
(4, 1, 1, 7.50);

create view vw_acervo_ordenado as
select 
	li.taxa_diaria,
	li.titulo,
	li.isbn,
	c.nome as categorias
from livros li
	join categorias c on li.categoria_id = c.id
order by li.taxa_diaria desc

create view vw_emprestimos_carlos as
select
	e.id,
	e.data_emprestimo,
	li.titulo,
	ie.quantidade,
	e.status
from itens_emprestimo ie
	join emprestimos e on e.id = ie.emprestimo_id
	join livros li on li.id = ie.livro_id
where e.leitor_id = 1

create view vw_total_emprestimos as
select
	e.id,
	le.nome,
	sum(ie.quantidade * ie.valor_diaria) as valor_total
from emprestimos e
	join leitores le on le.id = e.leitor_id
	join itens_emprestimo ie on ie.emprestimo_id = e.id
group by e.id,le.nome

select 
	c.nome,
	li.taxa_diaria
from livros li
	join categorias c on c.id = li.categoria_id
where c.nome = 'Ficção' and li.taxa_diaria > 5.00 and li.disponivel = true

create view vw_faturamento_por_categoria as
select 
	c.nome as categoria,
	sum(ie.quantidade * ie.valor_diaria) as faturamento_total
from itens_emprestimo ie
	join livros li on li.id = ie.livro_id
	join emprestimos e on e.id = ie.emprestimo_id
	join categorias c on c.id = li.categoria_id
where e.status = 'Devolvido'
group by c.nome
