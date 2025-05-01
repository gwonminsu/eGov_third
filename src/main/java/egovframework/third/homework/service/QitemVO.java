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
public class QitemVO {
	
    private String idx;
    
    private String questionIdx; // 질문 idx
    
    private String content; // 문항 내용
    
    private Integer seq; // 문항 순서
    
    private Timestamp createdAt; // 등록일
    
	private Timestamp updatedAt; // 수정일

}
