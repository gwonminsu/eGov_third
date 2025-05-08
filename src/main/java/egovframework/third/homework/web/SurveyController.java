package egovframework.third.homework.web;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.third.homework.service.QimageService;
import egovframework.third.homework.service.QimageVO;
import egovframework.third.homework.service.QuestionService;
import egovframework.third.homework.service.QuestionVO;
import egovframework.third.homework.service.SurveyService;
import egovframework.third.homework.service.SurveyVO;

@RestController
@RequestMapping("/api/survey")
public class SurveyController {
	
	private static final Logger log = LoggerFactory.getLogger(SurveyController.class);
	
	@Resource
	private ObjectMapper objectMapper;
	
    @Resource(name="propertiesService")
    private EgovPropertyService prop;

	@Resource(name = "surveyService")
	protected SurveyService surveyService;
	
    @Resource(name = "questionService")
    private QuestionService questionService;

    @Resource(name = "qimageService")
    private QimageService qimageService;
	
    // 설문 목록
    @PostMapping(value="/list.do", produces="application/json")
    public Map<String,Object> list(@RequestBody Map<String,Object> req) throws Exception {
    	// 파라미터 꺼내기
        int pageIndex = (Integer) req.get("pageIndex") <= 0 ? 1 : (Integer) req.get("pageIndex");
        int recordCountPerPage = (Integer) req.get("recordCountPerPage");
        String searchType = (String) req.get("searchType"); // "userName" or "title"
        String searchKeyword = (String) req.get("searchKeyword");
        Boolean onlyAvailable = (Boolean) req.get("onlyAvailable");
        
        // VO 에 페이징 정보만 세팅
        SurveyVO vo = new SurveyVO();
        vo.setPageIndex(pageIndex);
        vo.setRecordCountPerPage(recordCountPerPage);
        vo.setFirstIndex((pageIndex - 1) * recordCountPerPage);
        
        int totalCount = surveyService.getSurveyCount(vo, searchType, searchKeyword, onlyAvailable);
        List<SurveyVO> surveyList = surveyService.getSurveyList(vo, searchType, searchKeyword, onlyAvailable);
        
    	log.info("SELECT 설문 목록 JSON 데이터: {}", surveyList);
    	
        Map<String,Object> result = new HashMap<>();
        result.put("list", surveyList);
        result.put("totalCount", totalCount);
        
        return result;
    }

    // 설문 등록(해당 설문의 질문 등록 작업 포함)
    @PostMapping(value="/create.do", consumes="multipart/form-data", produces="application/json")
    public Map<String, String> write(
    		@RequestPart Map<String, Object> payload,
    		@RequestPart(value="files", required=false) List<MultipartFile> files) throws Exception {
    	SurveyVO surveyVO = objectMapper.convertValue(payload.get("survey"), SurveyVO.class);
        List<QuestionVO> questionList = objectMapper.convertValue(payload.get("questionList"), new TypeReference<List<QuestionVO>>() {});
        surveyService.createSurvey(surveyVO, questionList, files);
        return Collections.singletonMap("status","OK");
    }

    // 설문 상세 조회(설문 기본 정보)
    @PostMapping(value="/detail.do", consumes="application/json", produces="application/json")
    public SurveyVO detail(@RequestBody Map<String,String> param) throws Exception {
        return surveyService.getSurvey(param.get("idx"));
    }
    
	// 설문에 등록된 질문 리스트 조회
    @PostMapping(value="/questions.do", consumes="application/json", produces="application/json")
	public List<QuestionVO> questions(@RequestBody Map<String,String> param) throws Exception {
		String surveyIdx = param.get("surveyIdx");
		return questionService.getQuestionList(surveyIdx);
	}
    
    // 이미지 타입 질문의 이미지 정보 조회
    @PostMapping(value="/qimage.do", consumes="application/json", produces="application/json")
	public QimageVO qimage(@RequestBody Map<String,String> param) throws Exception {
		return qimageService.getQimageByQuestionIdx(param.get("questionIdx"));
	}

    // 설문 수정
    @PostMapping(value="/edit.do", consumes="multipart/form-data", produces="application/json")
    public Map<String,String> edit(
    		@RequestPart Map<String,Object> payload,
    		@RequestPart(value="files", required=false) List<MultipartFile> files) throws Exception {
    	SurveyVO surveyVO = objectMapper.convertValue(payload.get("survey"), SurveyVO.class);
        List<QuestionVO> questionList = objectMapper.convertValue(payload.get("questionList"), new TypeReference<List<QuestionVO>>() {});
        surveyService.modifySurvey(surveyVO, questionList, files);
        return Collections.singletonMap("status","OK");
    }

    // 설문 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param) throws Exception {
        String idx = param.get("idx");
    	surveyService.removeSurvey(idx);
        return Collections.singletonMap("status","OK");
    }
	
}
