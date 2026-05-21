package com.example.healthcoach;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class TestUser {
    @Id
    private Long id;
    private String name;
}