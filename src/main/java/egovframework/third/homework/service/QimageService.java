package egovframework.third.homework.service;

import org.springframework.web.multipart.MultipartFile;

//Service 인터페이스
public interface QimageService {

	// 질문 이미지 등록
    void createQimage(String questionIdx, MultipartFile file) throws Exception;
    
    // 질문에 소속된 질문 이미지 조회
    QimageVO getQimageByQuestionIdx(String questionIdx) throws Exception;
    
    // 질문 이미지 단일 조회
    QimageVO getQimage(String idx) throws Exception;
    
    // 질문 이미지 삭제
    void removeQimage(String idx) throws Exception;
    
    // 질문에 소속된 질문 이미지 삭제
    void removeQimageByQuestionIdx(String questionIdx) throws Exception;
    
}
