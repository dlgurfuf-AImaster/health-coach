package com.example.healthcoach.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.healthcoach.dto.LoginRequest;
import com.example.healthcoach.dto.SignupRequest;
import com.example.healthcoach.model.User;
import com.example.healthcoach.service.UserService;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    // 두뇌(Service)를 주입받습니다.
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 회원가입 API (POST http://10.0.2.2:8080/api/user/signup)
     */
    @PostMapping("/signup")
    public ResponseEntity<String> signup(@RequestBody SignupRequest request) {
        try {
            String result = userService.signup(request);
            return ResponseEntity.ok(result); // 성공 시 200 OK와 함께 메시지 반환
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage()); // 중복 등 에러 시 400 에러 반환
        }
    }

    /**
     * 로그인 API (POST http://10.0.2.2:8080/api/user/login)
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            User loggedInUser = userService.login(request);
            return ResponseEntity.ok(loggedInUser); // 로그인 성공 시 유저 정보 세션을 위해 리턴
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}