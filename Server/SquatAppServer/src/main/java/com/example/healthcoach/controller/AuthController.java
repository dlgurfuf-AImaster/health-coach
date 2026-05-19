package com.example.healthcoach.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.healthcoach.dto.LoginRequest;
import com.example.healthcoach.dto.SignupRequest;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	// 임시 회원가입 데이터 저장용 변수 (DB 연결 전)
	private String savedUsername = "";
	private String savedPassword = "";

	@PostMapping("/signup")
	public ResponseEntity<String> signup(@RequestBody SignupRequest request) {

		System.out.println("회원가입 요청 들어옴! ID: " + request.getUsername());

		savedUsername = request.getUsername();
		savedPassword = request.getPassword();

		return ResponseEntity.status(HttpStatus.CREATED).body("회원가입 성공");
	}

	@PostMapping("/login")
	public ResponseEntity<String> login(@RequestBody LoginRequest request) {
		System.out.println("로그인 요청 들어옴! ID: " + request.getUsername());

		if (request.getUsername().equals(savedUsername) && request.getPassword().equals(savedPassword)) {
			return ResponseEntity.ok("로그인 성공");
		} else {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("아이디 또는 비밀번호가 틀렸습니다.");
		}
	}
}
