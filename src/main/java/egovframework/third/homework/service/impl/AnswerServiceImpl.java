package egovframework.third.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.AnswerService;
import egovframework.third.homework.service.AnswerVO;
import egovframework.third.homework.service.SurveyResponseVO;

@Service("answerService")
public class AnswerServiceImpl extends EgovAbstractServiceImpl implements AnswerService {
	
	private static final Logger log = LoggerFactory.getLogger(AnswerServiceImpl.class);
	
	@Resource(name = "answerDAO")
	private AnswerDAO answerDAO;
	
	@Resource(name = "surveyResponseDAO")
	private SurveyResponseDAO sResDAO;

	// 설문의 모든 질문에 대한 답변들 일괄 등록
	@Override
	public void createAnswerList(SurveyResponseVO sRes, List<AnswerVO> answers) throws Exception {
		sResDAO.insertSurveyResponse(sRes); // 먼저 설문 응답 기록 추가
		log.info("INSERT 설문({})에 대한 사용자({})의 응답 기록 등록 성공", sRes.getSurveyIdx(), sRes.getUserIdx());
		for (AnswerVO a : answers) {
			a.setUserIdx(sRes.getUserIdx());
			answerDAO.insertAnswer(a); // 답변 등록
			log.info("INSERT 질문({})에 대한 답변({}) 등록 성공", a.getQuestionIdx(), a.getIdx());
		}
	}

	// 질문에 달린 답변 목록 조회
	@Override
	public List<AnswerVO> getAnswerList(String questionIdx) throws Exception {
		List<AnswerVO> list = answerDAO.selectAnswerListByQuestionIdx(questionIdx);
		log.info("SELECT 질문({})에 대한 답변 목록 조회 완료", questionIdx);
		return list;
	}

	// 답변 단일 조회
	@Override
	public AnswerVO getAnswer(String idx) throws Exception {
		AnswerVO vo = answerDAO.selectAnswer(idx);
		log.info("SELECT 답변({}) 조회 완료", idx);
		return vo;
	}
	
	// 질문 idx로 질문에 대한 응답 전부 삭제
	@Override
	public void removeAnswerList(String questionIdx) throws Exception {
		answerDAO.deleteAnswerByQuestionIdx(questionIdx);
		log.info("DELETE 질문({})에 대한 답변들 삭제 완료", questionIdx);
		
	}

}
