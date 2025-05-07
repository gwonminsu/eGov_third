package egovframework.third.homework.service;

import java.sql.Timestamp;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class QuestionVO {
	
    private String idx;
    
    private String surveyIdx; // 설문 idx
    
    private String type = "short"; // 질문 타입
    
    private String content; // 질문 내용
    
    private Integer seq; // 질문 순서
    
    private Boolean isRequired = false; // 필수 여부
    
    private Timestamp createdAt; // 등록일
    
	private Timestamp updatedAt; // 수정일

	private List<String> qitemList; // 객관식 문항 리스트
	
	private Boolean imageChanged; // 이미지 수정 여부
}
