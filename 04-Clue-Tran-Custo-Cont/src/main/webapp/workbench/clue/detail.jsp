<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
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


<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){

		//引用bootstrap的日期选择器
		$(".time").datetimepicker({
			minView: "month",
			language: "zh-CN",
			format: "yyyy-mm-dd",
			autoclose: true,
			today: true,
			pickerPosition: "bottom-left"
		})

		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		$("#showRemarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#showRemarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		//编辑按钮绑定事件
		$("#editBtn").click(function(){
			//获取clue对象后打开模态窗口
			$.ajax({
				url : "workbench/clue/getClueById.do",
				data : {"id" : "${clue.id}"},
				dataType : "json",
				success : function(data){
					//加载所有者信息列表
					$("#edit-owner").empty();		//清空
					var html = "";
					$.each(data.userList, function(i, n){
						html += "<option value='"+n.id+"'>"+n.name+"</option>";
					})
					$("#edit-owner").html(html);
					$("#edit-owner").val(data.clue.owner);

					$("#edit-id").val("${clue.id}");
					$("#edit-company").val(data.clue.company);
					$("#edit-appellation").val(data.clue.appellation);
					$("#edit-fullname").val(data.clue.fullname);
					$("#edit-job").val(data.clue.job);
					$("#edit-email").val(data.clue.email);
					$("#edit-phone").val(data.clue.phone);
					$("#edit-website").val(data.clue.website);
					$("#edit-mphone").val(data.clue.mphone);
					$("#edit-state").val(data.clue.state);
					$("#edit-source").val(data.clue.source);
					$("#edit-description").val(data.clue.description);
					$("#edit-contactSummary").val(data.clue.contactSummary);
					$("#edit-nextContactTime").val(data.clue.nextContactTime);
					$("#edit-address").val(data.clue.address);

					$("#editClueModal").modal("show");
				}
			})
		})

		//更新按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url : "workbench/clue/update.do",
				data : $("#editClueForm").serialize(),
				type : "post",
				dataType: "json",
				success : function (data) {
					if(data){
						document.location.href = "workbench/clue/detail.do?id="+"${clue.id}";
					}else{
						alert("更新线索失败");
					}
				}
			})
		})

		//删除按钮绑定事件
		$("#deleteBtn").click(function(){
			if(confirm("确定删除选中的记录吗?")){

				$.ajax({
					url : "workbench/clue/delete.do",
					data : {"id":"${clue.id}"},
					type : "post",
					dataType : "json",
					success : function(data){
						if (data){
							//删除成功
							window.history.back();
						}else {
							alert("删除线索失败");
						}
					}
				})
			}
		})

		//保存备注按钮绑定事件
		$("#saveRemark").click(function () {
			$.ajax({
				url : "workbench/clue/saveRemark.do",
				data : {"noteContent": $("#remark").val(),"clueId" : "${clue.id}"},
				type : "post",
				dataType : "json",
				success : function(data){

					//t添加成功后动态添加到jsp页面中
					if (data){
						//清空备注框
						$("#remark").val('');
						//重新获取备注列表
						showRemarkList();
					}else {
						alert("添加备注失败");
					}
				}
			})
		})

		//更新备注按钮绑定事件
		$("#updateRemarkBtn").click(function () {
			var id = $("#remarkId").val();
			$.ajax({
				url : "workbench/clue/updateRemark.do",
				data : {"id" : id, "noteContent" : $("#noteContent").val()},
				type : "post",
				dataType : "json",
				success : function(data){
					if (data){
						//重新加载备注
						showRemarkList();
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");
					}else {
						alert("更新备注失败");
					}
				}
			})
		})

		//绑定关联的模态窗口中的搜索框按下回车和值发生变化时
		$("#bound-condition").keydown(function(event){
			//如果是回车键
			if (event.keyCode==13){
				loadActivity();
				return false;
			}
		});

		//数据行复选框绑定事件
		$("#bound-activityBody").on("click",$("input[name=chkItem]"),function () {
			$("input[name=chkAll]").prop("checked",$("input[name=chkItem]").length == $("input[name=chkItem]:checked").length);
		})
		//全选复选框绑定事件
		$("input[name=chkAll]").click(function () {
			$("input[name=chkItem]").prop("checked", this.checked);
		})

		//确定绑定关联
		$("#boundBtn").click(function () {
			var $chkItem = $("input[name=chkItem]:checked");
			if($chkItem.length == 0){
				alert("请先选择需要关联的市场活动!")
			} else{
				var param = "cid=${clue.id}&"
				for(var i=0; i<$chkItem.length; i++){
					param += "aid="+$($chkItem[i]).val();
					if(i < $chkItem.length-1){
						param += "&";
					}
				}
				$.ajax({
					url : "workbench/clue/bound.do",
					data : param,
					type : "post",
					dataType : "json",
					success : function(data){
						if (data.success){
							//关联成功, 刷新
							showActivityList();
							//关闭模态窗口
							$("#bundModal").modal("hide");
							//清除文本框内容
							$("#bound-condition").val("")
							loadActivity();
							//取消全选
							$("input[name=chkAll]").prop("checked",false);
						}else {
							alert("关联市场活动失败");
						}
					}
				})
			}
		})

		//加载备注
		showRemarkList();
		//加载市场活动与线索关联
		showActivityList();

	});

	function showRemarkList() {
		$.ajax({
			url : "workbench/clue/getClueRemarkById.do",
			data : {"clueId": "${clue.id}"},
			dataType : "json",
			success : function(data){

				//清空备注框
				$("#showRemarkBody").empty();
				var cname = '${clue.fullname} ${clue.appellation}'+"-"+'${clue.company}';
				$.each(data,function (i,n) {

					$("#showRemarkBody").append(
							'<div class="remarkDiv" style="height: 60px;">\n' +
							'<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">\n' +
							'<div style="position: relative; top: -40px; left: 40px;" >\n' +
							'<h5 id="content'+n.id+'">'+n.noteContent+'</h5>\n' +
							'<font color="gray">线索</font> <font color="gray">-</font> <b>'+cname+'</b> <small style="color: gray;" id="small"> '+(n.editFlag==0? n.createTime : n.editTime)+' 由 '+(n.editFlag==0? n.createBy : n.editBy)+'</small>\n' +
							'<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">\n' +
							'<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
							'&nbsp;&nbsp;&nbsp;&nbsp;\n' +
							'<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF9797;"></span></a>\n' +
							'</div>\n' +
							'</div>\n' +
							'</div>')
				})
			}
		})
	}

	function editRemark(id) {
		//将id值赋给模态窗口的隐藏域
		$("#remarkId").val(id);
		//取出备注的值赋值给模态窗口
		$("#noteContent").val($("#content"+id).html());
		//展示模态窗口
		$("#editRemarkModal").modal("show");
	}

	function deleteRemark(id) {
		if(confirm("确定删除该备注吗?")){
			$.ajax({
				url : "workbench/clue/deleteRemark.do",
				data : {"id" : id},
				type : "post",
				dataType : "json",
				success : function(data){
					if (data){
						//删除成功, 重新获取备注
						showRemarkList();
					}else {
						alert("删除备注失败");
					}
				}
			})
		}
	}

	function showActivityList() {
		//先清空tbody
		$("#activityBody").empty();
		$.ajax({
			url : "workbench/clue/getActivityListByClueId.do",
			data : {"clueId" : "${clue.id}"},
			dataType : "json",
			success : function(data){
				if(data.success){
					$.each(data.activityList,function (i,n) {
						$("#activityBody").append(
								'<tr>\n' +
								'<td>'+n.name+'</td>\n' +
								'<td>'+n.startDate+'</td>\n' +
								'<td>'+n.endDate+'</td>\n' +
								'<td>'+n.owner+'</td>\n' +
								'<td><a href="javascript:void(0);" onclick="unbound(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>\n' +
								'</tr>')
					})
				}
			}
		})
	}
	
	function unbound(id) { //传进来的是关联关系表中的id
		if(window.confirm("确定解除该关联吗?")){
			$("#activityBody").empty();
			$.ajax({
				url : "workbench/clue/unbound.do",
				data : {"id":id},
				dataType : "json",
				success : function(data){
					if(data.success){
						showActivityList();
					}
					else{
						alert("解除关联失败!")
					}
				}
			})
		}
	}

	//绑定关联的模态窗口加载市场活动
	function loadActivity() {
		$("#bound-activityBody").empty();
		//用于选择绑定市场活动与线索的窗口
		if($.trim($("#bound-condition").val()) != '' ){
			$.ajax({
				url : "workbench/clue/getActivityList.do",
				data : {"condition":$("#bound-condition").val(),"clueId":"${clue.id}"},
				dataType : "json",
				success : function(data){
					if(data.success){
						$.each(data.activityList,function (i,n) {
							$("#bound-activityBody").append(
									'<tr>' +
									'<td><input type="checkbox" name="chkItem" value="'+n.id+'"/></td>' +
									'<td>'+n.name+'</td>' +
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
</script>

</head>
<body>

	<!-- 关联市场活动的模态窗口 -->
	<div class="modal fade" id="bundModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" id="bound-condition" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" name="chkAll"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="bound-activityBody">
							<!--ajax塞入数据-->
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-default" id="boundBtn">关联</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="editClueForm">

						<!---隐藏域-->
						<input type="hidden" id="edit-id" name="id"/>

						<div class="form-group">
							<label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner" name="owner">

								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" name="company">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation" name="appellation">
									<option value=""></option>
									<c:forEach items="${appellationList}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" name="fullname">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" name="job">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" name="email">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" name="phone">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" name="website">
							</div>
						</div>

						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" name="mphone">
							</div>
							<label for="edit-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state" name="state">
									<option></option>
									<c:forEach items="${clueStateList}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source" name="source">
									<option></option>
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description" name="description"></textarea>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary" name="contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime" name="nextContactTime" readonly>
								</div>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

						<div style="position: relative;top: 20px;">
							<div class="form-group">
								<label for="edit-address" class="col-sm-2 control-label">详细地址</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="1" id="edit-address" name="address"></textarea>
								</div>
							</div>
						</div>
					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${clue.fullname}${clue.appellation}<small>&ensp;${clue.company}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/clue/convert.jsp?id=${clue.id}&fullname=${clue.fullname}&appellation=${clue.appellation}&company=${clue.company}&owner=${clue.owner}';"><span class="glyphicon glyphicon-retweet"></span> 转换</button>
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.fullname}${clue.appellation}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.owner}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.company}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.job}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">线索状态</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.state}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${clue.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>${clue.description}</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>${clue.contactSummary}</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 100px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>${clue.address}</b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody" >
		<div class="page-header" id="forNewRemark">
			<h4>备注</h4>
		</div>
		<div id="showRemarkBody">
			<!--ajax展示备注-->
		</div>
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemark">保存</button>
				</p>
			</form>
		</div>
	</div>
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 市场活动与线索关联 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">
					<!---ajax动态塞入数据-->
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" data-toggle="modal" data-target="#bundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>