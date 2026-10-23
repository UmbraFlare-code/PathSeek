package com.pathseek.backend.user.dto;

import com.pathseek.backend.user.entity.UserRole;
import java.util.List;

public record RoleResponse(UserRole rol, String nombre, String descripcion, List<String> permisos) {}
