package egovframework.third.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.third.homework.service.AnswerService;
import egovframework.third.homework.service.AnswerVO;
import egovframework.third.homework.service.SurveyResponseVO;

@RestController
@RequestMapping("/api/answer")
public class AnswerController {
	
	private static final Logger log = LoggerFactory.getLogger(AnswerController.class);
	
	@Resource
	private ObjectMapper objectMapper;

    @Resource(name="answerService")
    private AnswerService answerService;

    // 설문의 질문에 대한 답변 목록 일괄 등록(해당 설문의 응답 기록 등록 작업 포함)
    @PostMapping(value="/submit.do", consumes="application/json", produces="application/json")
    public Map<String, String> submit(@RequestBody Map<String, Object> payload) throws Exception {
    	SurveyResponseVO sRes = objectMapper.convertValue(payload.get("surveyResponse"), SurveyResponseVO.class);
        List<AnswerVO> answerList = objectMapper.convertValue(payload.get("answerList"), new TypeReference<List<AnswerVO>>() {});
        answerService.createAnswerList(sRes, answerList);
        return Collections.singletonMap("status","OK");
    }
	
}
