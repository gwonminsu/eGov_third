package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.AnswerVO;

@Repository("answerDAO")
public class AnswerDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 질문에 답변 등록
	public void insertAnswer(AnswerVO vo) throws Exception {
		sqlSession.insert("answerDAO.insertAnswer", vo);
	}
    
    // 질문 idx로 질문에 달린 답변 목록 조회
    public List<AnswerVO> selectAnswerListByQuestionIdx(String questionIdx) throws Exception {
        return sqlSession.selectList("answerDAO.selectAnswerListByQuestionIdx", questionIdx);
    }
    
    // 질문 답변 단일 조회
    public AnswerVO selectAnswer(String idx) throws Exception {
        return sqlSession.selectOne("answerDAO.selectAnswer", idx);
    }
    
}
