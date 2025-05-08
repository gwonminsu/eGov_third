package egovframework.third.homework.service;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class AnswerVO {
	
    private String idx;
    
    private String questionIdx; // 질문 idx
    
    private String qitemIdx; // 문항 idx
    
    private String content; // 답변 내용
    
    private String userIdx; // 설문 참여자 idx
    
    private Timestamp createdAt; // 등록일

}
