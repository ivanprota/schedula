package com.ivan.prota.appointmentbooking.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.Date;

public class JwtUtil {

    private static final String SECRET = "92mnSFfHSirIXJPn+llhDIpIojOvFE7JPipPiHsXv7A=";

    private static final Key key = Keys.hmacShaKeyFor(java.util.Base64.getDecoder().decode(SECRET));

    public static String generateToken(String email) {
        return Jwts.builder()
            .setSubject(email)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 10))
            .signWith(key)
            .compact();
    }
}


