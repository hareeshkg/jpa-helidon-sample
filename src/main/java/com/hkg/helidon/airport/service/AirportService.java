package com.hkg.helidon.airport.service;

import java.util.List;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;

import com.hkg.helidon.airport.enitity.Airport;
import com.hkg.helidon.airport.repository.AirportRepository;

@ApplicationScoped
public class AirportService {
	
	private final AirportRepository  airportRepository;
	
	@Inject
	public AirportService(AirportRepository airportRepository) {
		this.airportRepository = airportRepository;
	}
	
	@Transactional
	public Airport save(Airport airport) {
		return airportRepository.createOrUpdate(airport);
	}
	
	public List<Airport> getAllAirports() {
		return airportRepository.getAllAirports();
	}
	
    @Transactional
	public void deleteByid(Long id) {
		airportRepository.deleteById(id);
	}

}
