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

import egovframework.third.homework.service.SurveyService;
import egovframework.third.homework.service.SurveyVO;

@RestController
@RequestMapping("/api/survey")
public class SurveyController {
	
	private static final Logger log = LoggerFactory.getLogger(SurveyController.class);

	@Resource(name = "surveyService")
	protected SurveyService surveyService;
	
    // 설문 목록
    @PostMapping(value="/list.do", produces="application/json")
    public List<SurveyVO> list() throws Exception {
    	List<SurveyVO> surveyList = surveyService.getSurveyList();
    	log.info("SELECT 설문 목록 JSON 데이터: {}", surveyList);
        return surveyList;
    }

    // 설문 등록
    @PostMapping(value="/create.do", consumes="application/json", produces="application/json")
    public Map<String,String> write(@RequestBody SurveyVO vo) {
        try {
        	surveyService.createSurvey(vo);
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
        	log.info(e.getMessage());
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 설문 상세
    @PostMapping(value="/detail.do", consumes="application/json", produces="application/json")
    public SurveyVO detail(@RequestBody Map<String,String> param) throws Exception {
        return surveyService.getSurvey(param.get("idx"));
    }

    // 설문 수정
    @PostMapping(value="/edit.do", consumes="application/json", produces="application/json")
    public Map<String,String> edit(@RequestBody SurveyVO vo) {
        try {
        	surveyService.modifySurvey(vo);
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 설문 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param) {
        try {
        	surveyService.removeSurvey(param.get("idx"));
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
            return Collections.singletonMap("error", e.getMessage());
        }
    }
	
}
