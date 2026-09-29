package com.pathseek.backend.auth.service;

import com.pathseek.backend.user.entity.User;

record IssuedRefreshToken(String value, User user) {
}
