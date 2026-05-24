package com.example.healthcoach.repository;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.healthcoach.model.User;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username); // 로그인 시 아이디로 조회용
}