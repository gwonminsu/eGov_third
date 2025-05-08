package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.QuestionVO;

@Repository("questionDAO")
public class QuestionDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 질문 등록
	public void insertQuestion(QuestionVO vo) throws Exception {
		sqlSession.insert("questionDAO.insertQuestion", vo);
	}
    
    // 설문 idx로 질문 목록 조회
    public List<QuestionVO> selectQuestionListBySurveyIdx(String surveyIdx) throws Exception {
        return sqlSession.selectList("questionDAO.selectQuestionListBySurveyIdx", surveyIdx);
    }
    
    // 질문 단일 조회
    public QuestionVO selectQuestion(String idx) throws Exception {
        return sqlSession.selectOne("questionDAO.selectQuestion", idx);
    }
    
    // 질문 수정
    public void updateQuestion(QuestionVO vo) throws Exception {
        sqlSession.update("questionDAO.updateQuestion", vo);
    }
    
    // 질문 삭제
    public void deleteQuestion(String idx) throws Exception {
        sqlSession.delete("questionDAO.deleteQuestion", idx);
    }
}
