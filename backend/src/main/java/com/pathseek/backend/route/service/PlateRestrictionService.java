package com.pathseek.backend.route.service;

import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.util.Collections;
import java.util.EnumMap;
import java.util.Map;
import java.util.Set;

/**
 * Restricción vehicular por último dígito de placa (RN-003, DS N.° 033-2012-MTC).
 *
 * <p>MVP Sprint 2: tabla configurable por defecto. Domingo y sábado sin
 * restricción. Ajustar los conjuntos si la municipalidad publica otro esquema.
 */
@Service
public class PlateRestrictionService {

    private final Map<DayOfWeek, Set<Integer>> restrictedByDay;

    public PlateRestrictionService() {
        Map<DayOfWeek, Set<Integer>> defaults = new EnumMap<>(DayOfWeek.class);
        defaults.put(DayOfWeek.MONDAY, Set.of(1, 2));
        defaults.put(DayOfWeek.TUESDAY, Set.of(3, 4));
        defaults.put(DayOfWeek.WEDNESDAY, Set.of(5, 6));
        defaults.put(DayOfWeek.THURSDAY, Set.of(7, 8));
        defaults.put(DayOfWeek.FRIDAY, Set.of(9, 0));
        defaults.put(DayOfWeek.SATURDAY, Set.of());
        defaults.put(DayOfWeek.SUNDAY, Set.of());
        this.restrictedByDay = Collections.unmodifiableMap(defaults);
    }

    public Set<Integer> restrictedDigitsFor(DayOfWeek day) {
        return restrictedByDay.getOrDefault(day, Set.of());
    }

    public boolean puedeCircular(DayOfWeek day, String placa, Integer restriccionPlacaDigito) {
        int lastDigit = lastDigitOf(placa, restriccionPlacaDigito);
        if (lastDigit < 0) {
            return true;
        }
        return !restrictedDigitsFor(day).contains(lastDigit);
    }

    public int lastDigitOf(String placa, Integer override) {
        if (override != null) {
            return override;
        }
        if (placa == null) {
            return -1;
        }
        for (int i = placa.length() - 1; i >= 0; i--) {
            char c = placa.charAt(i);
            if (Character.isDigit(c)) {
                return c - '0';
            }
        }
        return -1;
    }
}
