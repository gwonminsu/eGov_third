package egovframework.third.homework.service;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

// 설문 응답 기록
@Getter
@Setter
@ToString
@NoArgsConstructor
public class SurveyResponseVO {
	
    private String idx;
    
    private String surveyIdx; // 설문 idx
    
    private String userIdx; // 설문 참여자 idx
    
    private Timestamp createdAt; // 등록일
    
    private String userName; // 사용자 이름
    
    private String userId; // 사용자 아이디

}
