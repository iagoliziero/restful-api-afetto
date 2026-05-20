package br.com.fiap.java_afetto.dto.usuario;

import org.springframework.hateoas.Link;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;

public record UsuarioLista(String nome, String telefone, Link linkUsuario, Link linkEndereco) {
}
