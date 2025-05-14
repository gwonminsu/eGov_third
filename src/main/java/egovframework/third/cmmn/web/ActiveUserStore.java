package egovframework.third.cmmn.web;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.springframework.stereotype.Component;

@Component
public class ActiveUserStore implements HttpSessionListener {
	
    // userId → HttpSession
    private static final Map<String, HttpSession> sessions = new ConcurrentHashMap<>();

    // 로그인 시 호출하여 중복 로그인 체크
    public boolean register(String userId, HttpSession session) {
        // 이미 같은 userId 세션이 남아있으면 false 리턴
        HttpSession existing = sessions.putIfAbsent(userId, session);
        return existing == null;
    }

    // 로그아웃 시 또는 세션 종료 시 호출
    public void unregister(String userId) {
        sessions.remove(userId);
    }

    // 톰캣에서 세션 만료될 때 맵에서 제거
	@Override
	public void sessionCreated(HttpSessionEvent se) {
        HttpSession dead = se.getSession();
        sessions.entrySet().removeIf(e -> e.getValue().getId().equals(dead.getId()));
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent se) {
		
	}

}
