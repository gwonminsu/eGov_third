package egovframework.third.homework.service;

import java.util.List;

//Service 인터페이스
public interface QuestionService {

	// 질문 등록
    void createQuestion(QuestionVO vo) throws Exception;
    
    // 설문에 소속된 질문 리스트 조회
    List<QuestionVO> getQuestionList(String surveyIdx) throws Exception;
    
    // 질문 단일 조회
    QuestionVO getQuestion(String idx) throws Exception;
    
    // 질문 수정
    void modifyQuestion(QuestionVO vo) throws Exception;
    
    // 질문 삭제
    void removeQuestion(String idx) throws Exception;
    
}
