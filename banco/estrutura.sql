CREATE DATABASE IF NOT EXISTS plataforma_modular
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE plataforma_modular;

-- ==========================================
-- PESSOAS
-- ==========================================

CREATE TABLE pessoas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) UNIQUE,
    nome_completo VARCHAR(150) NOT NULL,
    nome_social VARCHAR(150),
    cpf VARCHAR(14),
    rg VARCHAR(30),
    data_nascimento DATE,
    sexo VARCHAR(30),
    telefone VARCHAR(30),
    email VARCHAR(150),
    foto VARCHAR(500),

    cep VARCHAR(10),
    endereco VARCHAR(200),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    municipio VARCHAR(100),
    estado VARCHAR(2),

    status ENUM('ATIVO','INATIVO') DEFAULT 'ATIVO',

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_pessoas_cpf (cpf),
    INDEX idx_pessoas_nome (nome_completo),
    INDEX idx_pessoas_email (email)
);

-- ==========================================
-- USUÁRIOS
-- ==========================================

CREATE TABLE usuarios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    pessoa_id BIGINT UNSIGNED NOT NULL,

    usuario VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(150),
    senha_hash VARCHAR(255) NOT NULL,

    status ENUM('ATIVO','BLOQUEADO','INATIVO')
        DEFAULT 'ATIVO',

    ultimo_acesso DATETIME,

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (pessoa_id)
        REFERENCES pessoas(id)
);

-- ==========================================
-- PERFIS
-- ==========================================

CREATE TABLE perfis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255),

    status ENUM('ATIVO','INATIVO')
        DEFAULT 'ATIVO',

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- USUÁRIO x PERFIL
-- ==========================================

CREATE TABLE usuario_perfis (
    usuario_id BIGINT UNSIGNED NOT NULL,
    perfil_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (usuario_id, perfil_id),

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    FOREIGN KEY (perfil_id)
        REFERENCES perfis(id)
        ON DELETE CASCADE
);

-- ==========================================
-- MÓDULOS
-- ==========================================

CREATE TABLE modulos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    nome VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(255),

    icone VARCHAR(100),

    ordem INT DEFAULT 0,

    visivel BOOLEAN DEFAULT TRUE,
    ativo BOOLEAN DEFAULT TRUE,

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- ==========================================
-- PERMISSÕES
-- ==========================================

CREATE TABLE permissoes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    modulo_id BIGINT UNSIGNED NOT NULL,

    codigo VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,

    pode_visualizar BOOLEAN DEFAULT FALSE,
    pode_criar BOOLEAN DEFAULT FALSE,
    pode_editar BOOLEAN DEFAULT FALSE,
    pode_excluir BOOLEAN DEFAULT FALSE,
    pode_aprovar BOOLEAN DEFAULT FALSE,
    pode_exportar BOOLEAN DEFAULT FALSE,
    pode_administrar BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (modulo_id)
        REFERENCES modulos(id)
        ON DELETE CASCADE
);

-- ==========================================
-- PERFIL x PERMISSÃO
-- ==========================================

CREATE TABLE perfil_permissoes (
    perfil_id BIGINT UNSIGNED NOT NULL,
    permissao_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (perfil_id, permissao_id),

    FOREIGN KEY (perfil_id)
        REFERENCES perfis(id)
        ON DELETE CASCADE,

    FOREIGN KEY (permissao_id)
        REFERENCES permissoes(id)
        ON DELETE CASCADE
);

-- ==========================================
-- MENUS
-- ==========================================

CREATE TABLE menus (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    modulo_id BIGINT UNSIGNED,

    menu_pai_id BIGINT UNSIGNED NULL,

    nome VARCHAR(100) NOT NULL,
    rota VARCHAR(255),

    icone VARCHAR(100),

    ordem INT DEFAULT 0,

    visivel BOOLEAN DEFAULT TRUE,
    ativo BOOLEAN DEFAULT TRUE,

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (modulo_id)
        REFERENCES modulos(id)
        ON DELETE SET NULL,

    FOREIGN KEY (menu_pai_id)
        REFERENCES menus(id)
        ON DELETE SET NULL
);

-- ==========================================
-- CONFIGURAÇÕES DO SISTEMA
-- ==========================================

CREATE TABLE configuracoes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    chave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT,

    tipo VARCHAR(30) DEFAULT 'texto',

    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);

-- ==========================================
-- CAMPOS PERSONALIZADOS
-- ==========================================

CREATE TABLE campos_personalizados (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    modulo_id BIGINT UNSIGNED NOT NULL,

    nome VARCHAR(100) NOT NULL,
    chave VARCHAR(100) NOT NULL,

    tipo VARCHAR(50) NOT NULL,

    obrigatorio BOOLEAN DEFAULT FALSE,

    ordem INT DEFAULT 0,

    configuracao JSON,

    ativo BOOLEAN DEFAULT TRUE,

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (modulo_id)
        REFERENCES modulos(id)
        ON DELETE CASCADE
);

-- ==========================================
-- REGISTROS DOS CAMPOS PERSONALIZADOS
-- ==========================================

CREATE TABLE valores_personalizados (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    campo_id BIGINT UNSIGNED NOT NULL,

    registro_id BIGINT UNSIGNED NOT NULL,

    valor TEXT,

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,

    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (campo_id)
        REFERENCES campos_personalizados(id)
        ON DELETE CASCADE,

    INDEX idx_valores_registro (registro_id)
);

-- ==========================================
-- AUDITORIA
-- ==========================================

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    usuario_id BIGINT UNSIGNED NULL,

    modulo VARCHAR(100),

    tabela VARCHAR(100),

    registro_id BIGINT UNSIGNED,

    acao VARCHAR(50) NOT NULL,

    descricao TEXT,

    dados_anteriores JSON,
    dados_novos JSON,

    ip VARCHAR(45),

    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);

-- ==========================================
-- CONFIGURAÇÕES INICIAIS
-- ==========================================

INSERT INTO configuracoes
(chave, valor, tipo)
VALUES
('nome_sistema', 'Plataforma Modular', 'texto'),
('titulo_navegador', 'Plataforma Modular', 'texto'),
('logo_principal', '', 'imagem'),
('favicon', '', 'imagem'),
('cor_primaria', '#003B66', 'cor'),
('cor_secundaria', '#1A5A85', 'cor'),
('cor_fundo', '#F5F6F8', 'cor'),
('cor_texto', '#333333', 'cor'),
('menu_lateral', 'sim', 'boolean'),
('modo_manutencao', 'nao', 'boolean');

-- ==========================================
-- MÓDULO INICIAL
-- ==========================================

INSERT INTO modulos
(nome, slug, descricao, icone, ordem)
VALUES
(
    'Sistema',
    'sistema',
    'Configurações e administração da plataforma',
    'settings',
    1
);

-- ==========================================
-- PERFIL TI
-- ==========================================

INSERT INTO perfis
(nome, descricao)
VALUES
(
    'TI',
    'Administrador geral da plataforma'
);
