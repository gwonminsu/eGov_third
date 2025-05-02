package egovframework.third.homework.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.third.homework.service.QitemVO;
import egovframework.third.homework.service.QuestionService;
import egovframework.third.homework.service.QuestionVO;

@Service("questionService")
public class QuestionServiceImpl extends EgovAbstractServiceImpl implements QuestionService {
	
	private static final Logger log = LoggerFactory.getLogger(QuestionServiceImpl.class);
	
	@Resource(name = "questionDAO")
	private QuestionDAO questionDAO;
	
    @Resource(name="qitemDAO")
    private QitemDAO qitemDAO;
    
    @Resource(name="qimageDAO")
    private QimageDAO qimageDAO;

	// 질문 등록
	@Override
	public void createQuestion(QuestionVO vo) throws Exception {
		questionDAO.insertQuestion(vo);
		log.info("INSERT 설문({})에 질문 등록 성공 idx: {}", vo.getSurveyIdx(), vo.getIdx());
	}

	// 설문에 소속된 질문 리스트 조회
	@Override
	public List<QuestionVO> getQuestionList(String surveyIdx) throws Exception {
		List<QuestionVO> list = questionDAO.selectQuestionListBySurveyIdx(surveyIdx);
		log.info("SELECT 설문({})에 대한 질문 목록 조회 완료", surveyIdx);
		
		for (QuestionVO q : list) {
			// 객관식 문항을 순서대로 세팅
            List<QitemVO> items = qitemDAO.selectQitemListByQuestionIdx(q.getIdx());
            List<String> optionList = new ArrayList<>();
            for (QitemVO item: items) {
            	optionList.add(item.getContent());
            }
            q.setQitemList(optionList);
		}
		return list;
	}

	// 질문 단일 조회
	@Override
	public QuestionVO getQuestion(String idx) throws Exception {
		QuestionVO vo = questionDAO.selectQuestion(idx);
		log.info("SELECT 질문({}) 조회 완료", idx);
		return null;
	}

	// 질문 수정
	@Override
	public void modifyQuestion(QuestionVO vo) throws Exception {
		questionDAO.updateQuestion(vo);
		log.info("UPDATE 질문({}) 수정 완료", vo.getIdx());
	}

	// 질문 삭제
	@Override
	public void removeQuestion(String idx) throws Exception {
		questionDAO.deleteQuestion(idx);
		log.info("DELETE 질문({}) 삭제 완료", idx);
	}

}
