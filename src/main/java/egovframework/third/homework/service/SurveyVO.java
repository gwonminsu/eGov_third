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
public class SurveyVO {

    private String idx;
    private String authorIdx; // 작성자(관리자) idx
    private String editorIdx; // 수정자(관리자) idx
    private String userName; // 작성자 이름
    private String title; // 제목
    private String description; // 설문 개요
    private Timestamp startDate; // 등록일
	private Timestamp endDate; // 수정일
    private boolean isUse; // 사용 유무
    private Timestamp createdAt; // 등록일
	private Timestamp updatedAt; // 수정일
	
}
