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
public class QimageVO {
	
    private String idx;
    
    private String questionIdx; // 질문 idx
    
    private String fileName; // 첨부 이미지 이름
    
    private String fileUuid; // 첨부 이미지 UUID

    private String filePath; // 첨부 이미지 주소

    private long fileSize; // 첨부 이미지 사이즈
    
    private String ext; // 확장자
    
    private Timestamp createdAt; // 등록일

}
