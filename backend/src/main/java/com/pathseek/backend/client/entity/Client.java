package com.pathseek.backend.client.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "clientes")
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "cliente_id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "nombre", nullable = false, length = 150)
    private String nombre;

    @Column(name = "direccion", nullable = false, length = 200)
    private String direccion;

    @Column(name = "punto_referencia", length = 200)
    private String puntoReferencia;

    @Column(name = "telefono", length = 20)
    private String telefono;

    @Column(name = "contacto", length = 100)
    private String contacto;

    @Column(name = "gps_lat", precision = 10, scale = 7)
    private BigDecimal gpsLat;

    @Column(name = "gps_lon", precision = 10, scale = 7)
    private BigDecimal gpsLon;

    @Column(name = "ventana_inicio_preferida", length = 5)
    private String ventanaInicioPreferida;

    @Column(name = "ventana_fin_preferida", length = 5)
    private String ventanaFinPreferida;

    @Column(name = "activo", nullable = false)
    private Boolean activo = true;

    @Column(name = "creado_en", nullable = false, updatable = false)
    private Instant creadoEn = Instant.now();

    public Client() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getPuntoReferencia() {
        return puntoReferencia;
    }

    public void setPuntoReferencia(String puntoReferencia) {
        this.puntoReferencia = puntoReferencia;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getContacto() {
        return contacto;
    }

    public void setContacto(String contacto) {
        this.contacto = contacto;
    }

    public BigDecimal getGpsLat() {
        return gpsLat;
    }

    public void setGpsLat(BigDecimal gpsLat) {
        this.gpsLat = gpsLat;
    }

    public BigDecimal getGpsLon() {
        return gpsLon;
    }

    public void setGpsLon(BigDecimal gpsLon) {
        this.gpsLon = gpsLon;
    }

    public String getVentanaInicioPreferida() {
        return ventanaInicioPreferida;
    }

    public void setVentanaInicioPreferida(String ventanaInicioPreferida) {
        this.ventanaInicioPreferida = ventanaInicioPreferida;
    }

    public String getVentanaFinPreferida() {
        return ventanaFinPreferida;
    }

    public void setVentanaFinPreferida(String ventanaFinPreferida) {
        this.ventanaFinPreferida = ventanaFinPreferida;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public Instant getCreadoEn() {
        return creadoEn;
    }

    public void setCreadoEn(Instant creadoEn) {
        this.creadoEn = creadoEn;
    }
}
