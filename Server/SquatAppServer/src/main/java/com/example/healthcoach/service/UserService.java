package com.example.healthcoach.service;

import java.util.Optional;

import org.springframework.stereotype.Service;

import com.example.healthcoach.dto.LoginRequest;
import com.example.healthcoach.dto.SignupRequest;
import com.example.healthcoach.model.User;
import com.example.healthcoach.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;

    // 생성자 주입으로 DB 창고지기(Repository)를 가져옵니다.
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 회원가입 로직
     */
    public String signup(SignupRequest request) {
        // 1. 아이디 중복 검사
        Optional<User> existingUser = userRepository.findByUsername(request.getUsername());
        if (existingUser.isPresent()) {
            throw new IllegalArgumentException("이미 존재하는 아이디입니다.");
        }

        // 2. DTO 상자에서 알맹이를 꺼내 진짜 User 엔티티(DB용) 객체로 변환
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(request.getPassword()); // 💡실제 서비스에선 암호화(BCrypt 등)를 해야 하지만 일단 기본으로 매핑!
        user.setName(request.getName());

        // 3. DB에 최종 저장
        userRepository.save(user);
        return "회원가입 성공";
    }

    /**
     * 로그인 로직
     */
    public User login(LoginRequest request) {
        // 1. 아이디로 유저 찾기
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 아이디입니다."));

        // 2. 비밀번호 대조
        if (!user.getPassword().equals(request.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }

        // 3. 로그인 성공 시 유저 정보 반환 (나중에 토큰을 써도 되지만 우선 객체 반환)
        return user;
    }
}