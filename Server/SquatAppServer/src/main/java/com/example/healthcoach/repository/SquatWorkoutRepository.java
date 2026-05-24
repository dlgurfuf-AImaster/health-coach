package com.example.healthcoach.repository;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.healthcoach.model.SquatWorkout;

public interface SquatWorkoutRepository extends JpaRepository<SquatWorkout, Long> {
    List<SquatWorkout> findByUserIdOrderByEndTimeDesc(Long userId); // 특정 유저의 최근 기록 분석용
}