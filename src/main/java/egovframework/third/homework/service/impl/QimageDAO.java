package egovframework.third.homework.service.impl;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.third.homework.service.QimageVO;

@Repository("qimageDAO")
public class QimageDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 질문 이미지 등록
	public void insertQimage(QimageVO vo) throws Exception {
		sqlSession.insert("qimageDAO.insertQimage", vo);
	}
    
    // 질문 idx로 질문 이미지 조회
    public QimageVO selectQimageByQuestionIdx(String questionIdx) {
        return sqlSession.selectOne("qimageDAO.selectQimageByQuestionIdx", questionIdx);
    }
    
    // 질문 이미지 단일 조회
    public QimageVO selectQimage(String idx) {
        return sqlSession.selectOne("qimageDAO.selectQimage", idx);
    }
    
    // 질문 이미지 삭제
    public void deleteQimage(String idx) {
        sqlSession.delete("qimageDAO.deleteQimage", idx);
    }
        
    // 질문에 있는 질문 이미지 삭제
    public void deleteQimageByQuestionIdx(String questionIdx) {
        sqlSession.update("qimageDAO.deleteQimageByQuestionIdx", questionIdx);
    }
    
}
