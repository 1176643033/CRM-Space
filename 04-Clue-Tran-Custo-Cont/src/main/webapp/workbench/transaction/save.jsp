<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");
	Set<String> set = pMap.keySet();
%>

<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">

		//存放阶段与可能性对应的变量
		var json ={
			<%
				for(String key:set){
					String value = pMap.get(key);
			%>
					"<%=key%>" : <%=value%>,
			<%
				}
			%>
		}

		$(function () {

			//引用bootstrap的日期选择器
			$(".time").datetimepicker({
				minView: "month",
				language: "zh-CN",
				format: "yyyy-mm-dd",
				autoclose: true,
				today: true,
				pickerPosition: "bottom-left"
			})

			//自动补全的操作
			$("#create-customerName").typeahead({
				source: function (query, process) {
					$.get(
							"workbench/transaction/getCustomerName.do",
							{ "name" : query },
							function (data) {
								//alert(data);
								process(data);
							},
							"json"
					);
				},
				delay: 1000
			});

			//为搜索市场活动源绑定事件
			$("#create-activitySrc").click(function () {
				$("#searchActivityModal").modal("show");
			});

			//模糊查询市场活动源绑定事件
			$("#search-condition").keydown(function (event) {
				if(event.keyCode==13){
					loadActivity();
					return false;
				}
			})

			//为提交(市场活动源)按钮绑定事件,填充市场活动源(市场活动名字和该id)
			$("#submitActivityBtn").click(function(){
				var id = $("input[name=radioItem]:checked").val();

				$("#create-activitySrcId").val(id)
				$("#create-activitySrc").val($("#"+id).html());
				$("#searchActivityModal").modal("hide");
				//重置数据行的radio
				$("input[name=radioItem]").prop("checked", false);
			})

			//为点击时弹出框搜索联系人绑定事件
			$("#create-contactsName").click(function () {
				$("#findContacts").modal("show");
			});

			//模糊查询联系人绑定事件
			$("#find-condition").keydown(function (event) {
				if(event.keyCode==13){
					loadContacts();
					return false;
				}
			})

			//为提交(联系人按钮绑定事件
			$("#selectContactsBtn").click(function(){
				var id = $("input[name=radioItem]:checked").val();

				$("#create-contactsId").val(id)
				$("#create-contactsName").val($("#"+id).html());
				$("#findContacts").modal("hide");

				//重置数据行的radio
				$("input[name=radioItem]").prop("checked", false);
			})

			//为阶段的下拉框,绑定选中下拉框的事件,根据选中的阶段自动填写可能性的值
			$("#create-transactionStage").change(function(){
				//取得下拉框选中的阶段
				var stage = $("#create-transactionStage").val();
				$("#create-possibility").val(json[stage]);
			})

			//确认保存按钮绑定事件
			$("#submitBtn").click(function(){
				if(window.confirm("确定创建该交易吗?")){
					$("#saveTranForm").submit();
				}

			})
		})

		//选择市场活动的Ajax获取activityList
		function loadActivity() {
			$("#activitySourceTable").empty();
			//用于选择绑定市场活动与线索的窗口
			if($.trim($("#search-condition").val()) != '' ){
				$.ajax({
					url : "workbench/transaction/getActivityListByCondition.do",
					data : {"condition":$("#search-condition").val()},
					dataType : "json",
					success : function(data){
						if(data.success){
							$.each(data.activityList,function (i,n) {
								$("#activitySourceTable").append(
										'<tr>' +
										'<td><input type="radio" name="radioItem" value="'+n.id+'"/></td>' +
										'<td id="'+n.id+'">'+n.name+'</td>' +
										'<td>'+n.startDate+'</td>' +
										'<td>'+n.endDate+'</td>' +
										'<td>'+n.owner+'</td>' +
										'</tr>'
								)
							})
						}
					}
				})
			}
		}

		//选择联系人的Ajax获取contactsList
		function loadContacts() {
			$("#contactsBody").empty();
			if($.trim($("#find-condition").val()) != '' ){
				$.ajax({
					url : "workbench/transaction/getContactsListByCondition.do",
					data : {"condition":$("#find-condition").val()},
					dataType : "json",
					success : function(data){
						if(data.success){
							$.each(data.contactsList,function (i,n) {
								$("#contactsBody").append(
										'<tr>' +
										'<td><input type="radio" name="radioItem" value="'+n.id+'"/></td>' +
										'<td id="'+n.id+'">'+n.fullname+n.appellation+'</td>' +
										'<td>'+n.email+'</td>' +
										'<td>'+n.mphone+'</td>' +
										'</tr>'
								)
							})
						}
					}
				})
			}
		}


	</script>
</head>
<body>

	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
							<div class="form-group has-feedback">
								<input type="text" class="form-control" style="width: 300px;" id="search-condition" placeholder="请输入市场活动名称，支持模糊查询">
								<span class="glyphicon glyphicon-search form-control-feedback"></span>
							</div>
						</form>
					</div>
					<table id="activitySourceTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
						<tr style="color: #B3B3B3;">
							<td></td>
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
						</thead>
						<tbody id="activityBody">
						<!--ajax塞入数据-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="submitActivityBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="find-condition" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsBody">
							<!--Ajax塞入数据-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="selectContactsBtn">选中</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="submitBtn">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" id="saveTranForm" action="workbench/transaction/save.do" method="post" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner" name="owner">
				  <c:forEach items="${dataList}" var="user">
					  <option value="${user.id}" ${sessionScope.user.id eq user.id ? "selected":""} > ${user.name}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName" name="name">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time" id="create-expectedClosingDate" name="expectedDate" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建" name="customerId">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage" name="stage">
				  <c:forEach items="${stageList}" var="s">
					  <option></option>
					  <option value="${s.value}">${s.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType" name="type">
				  <option></option>
					<c:forEach items="${transactionTypeList}" var="t">
						<option value="${t.value}">${t.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource" name="source">
				  <option></option>
					<c:forEach items="${sourceList}" var="s">
						<option value="${s.value}">${s.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc" readonly>
				<input type="hidden" id="create-activitySrcId" name="activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName" readonly>
				<input type="hidden" id="create-contactsId" name="contactsId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe" name="description"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time" id="create-nextContactTime" name="nextContactTime" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>