package com.example.healthcoach.model;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "squat_workout")
public class SquatWorkout {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	// 💡 여러 개의 스쿼트 기록이 하나의 유저에게 연결됩니다. (N:1 관계)
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "user_id", nullable = false)
	private User user;

	private int totalCount; // 총 시도 횟수
	private int successCount; // 성공 횟수
	private int badWaistAngleCount; // 허리를 못 편 횟수 (경향성 데이터)
	private int shallowSquatCount; // 허벅지를 더 내려야 했던 횟수 (경향성 데이터)

	private LocalDateTime endTime;

	@PrePersist
	protected void onCreate() {
		this.endTime = LocalDateTime.now(); // 데이터 저장 시 현재 시간 자동 입력
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getSuccessCount() {
		return successCount;
	}

	public void setSuccessCount(int successCount) {
		this.successCount = successCount;
	}

	public int getBadWaistAngleCount() {
		return badWaistAngleCount;
	}

	public void setBadWaistAngleCount(int badWaistAngleCount) {
		this.badWaistAngleCount = badWaistAngleCount;
	}

	public int getShallowSquatCount() {
		return shallowSquatCount;
	}

	public void setShallowSquatCount(int shallowSquatCount) {
		this.shallowSquatCount = shallowSquatCount;
	}

	public LocalDateTime getEndTime() {
		return endTime;
	}

	public void setEndTime(LocalDateTime endTime) {
		this.endTime = endTime;
	}
}