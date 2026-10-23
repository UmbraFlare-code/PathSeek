package com.pathseek.backend.order.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.order.dto.OrderRequest;
import com.pathseek.backend.order.dto.OrderResponse;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.security.CurrentActor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class OrderService {

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> findAll() {
        return orderRepository.findAll(Sort.by("ventanaInicio").and(Sort.by("prioridad"))).stream()
                .filter(order -> !CurrentActor.hasRole("CLIENTE") || order.getClienteId().equals(CurrentActor.subject()))
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public OrderResponse findById(UUID id) {
        return toResponse(getOrder(id));
    }

    @Transactional
    public OrderResponse create(OrderRequest request) {
        if (CurrentActor.hasRole("CLIENTE")) {
            request = new OrderRequest(CurrentActor.subject(), request.direccion(), request.gpsLat(), request.gpsLon(),
                    request.peso(), request.volumen(), request.ventanaInicio(), request.ventanaFin(),
                    request.prioridad(), request.tipoProducto(), OrderStatus.PENDIENTE);
        }
        validateWindow(request.ventanaInicio(), request.ventanaFin());
        assertNoDuplicate(request, UUID.randomUUID());

        Order order = new Order();
        apply(order, request, true);
        return toResponse(orderRepository.saveAndFlush(order));
    }

    @Transactional
    public OrderResponse update(UUID id, OrderRequest request) {
        validateWindow(request.ventanaInicio(), request.ventanaFin());

        Order order = getOrderForUpdate(id);
        assertNoDuplicate(request, id);
        apply(order, request, false);
        return toResponse(orderRepository.saveAndFlush(order));
    }

    @Transactional
    public void delete(UUID id) {
        Order order = getOrderForUpdate(id);
        orderRepository.delete(order);
    }

    private Order getOrder(UUID id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("No se encontró el pedido solicitado"));
        if (CurrentActor.hasRole("CLIENTE") && !order.getClienteId().equals(CurrentActor.subject())) {
            throw new AccessDeniedException("El pedido pertenece a otro cliente");
        }
        return order;
    }

    private Order getOrderForUpdate(UUID id) {
        Order order = orderRepository.lockForUpdate(id)
                .orElseThrow(() -> new ResourceNotFoundException("No se encontró el pedido solicitado"));
        if (CurrentActor.hasRole("CLIENTE") && !order.getClienteId().equals(CurrentActor.subject())) {
            throw new AccessDeniedException("El pedido pertenece a otro cliente");
        }
        return order;
    }

    private void apply(Order order, OrderRequest request, boolean creating) {
        order.setClienteId(request.clienteId().trim());
        order.setDireccion(request.direccion().trim());
        order.setGpsLat(request.gpsLat());
        order.setGpsLon(request.gpsLon());
        order.setPeso(request.peso());
        order.setVolumen(request.volumen());
        order.setVentanaInicio(request.ventanaInicio());
        order.setVentanaFin(request.ventanaFin());
        order.setPrioridad(request.prioridad());
        order.setTipoProducto(request.tipoProducto());
        if (request.estado() != null) {
            order.setEstado(request.estado());
        } else if (creating) {
            order.setEstado(OrderStatus.PENDIENTE);
        }
    }

    private OrderResponse toResponse(Order order) {
        return new OrderResponse(
                order.getId(),
                order.getClienteId(),
                order.getDireccion(),
                order.getGpsLat(),
                order.getGpsLon(),
                order.getPeso(),
                order.getVolumen(),
                order.getVentanaInicio(),
                order.getVentanaFin(),
                order.getPrioridad(),
                order.getTipoProducto(),
                order.getEstado());
    }

    private void validateWindow(String inicio, String fin) {
        if (fin.compareTo(inicio) <= 0) {
            throw new BusinessRuleException(
                    "INVALID_ORDER_WINDOW",
                    "La hora de fin debe ser posterior a la hora de inicio");
        }
    }

    private void assertNoDuplicate(OrderRequest request, UUID excludedId) {
        if (request.estado() == OrderStatus.CANCELADO || request.estado() == OrderStatus.ENTREGADO) return;
        boolean duplicated = orderRepository
                .existsByClienteIdAndDireccionAndVentanaInicioAndVentanaFinAndEstadoInAndIdNot(
                        request.clienteId().trim(),
                        request.direccion().trim(),
                        request.ventanaInicio(),
                        request.ventanaFin(),
                        List.of(OrderStatus.PENDIENTE, OrderStatus.EN_RUTA),
                        excludedId);
        if (duplicated) {
            throw new BusinessConflictException(
                    "ORDER_DUPLICATE",
                    "Ya existe un pedido activo con el mismo cliente, dirección y ventana de tiempo");
        }
    }
}
