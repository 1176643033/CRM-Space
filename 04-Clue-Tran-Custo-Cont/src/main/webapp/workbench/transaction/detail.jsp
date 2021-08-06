<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bjpowernode.setting.domain.DicValue" %>
<%@ page import="com.bjpowernode.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

	//准备阶段和可能性之间的对应关系
	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");

	//准备字典类型stage的字典值列表
	List<DicValue> dvList = (List<DicValue>)application.getAttribute("stageList");
	//根据pMap准备的key集合
	Set<String> set = pMap.keySet();

	//找到前面正常阶段和后面丢失阶段的分界点下标
	int point = 0;
	for(int i=0; i<dvList.size(); i++){
		//取得每一个字典值
		DicValue dv = dvList.get(i);
		//从dv中取得value
		String stage = dv.getValue();
		//根据stage取得possibility
		String possibility = pMap.get(stage);
		//如果可能性为0,说明找到了分界点
		if("0".equals(possibility)){
			point = i;
			break;
		}
	}

%>

<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;

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
	
	$(function(){

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
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });

		//保存备注按钮绑定事件
		$("#saveRemark").click(function () {
			$.ajax({
				url : "workbench/transaction/saveRemark.do",
				data : {"noteContent": $("#remark").val(),"tranId" : "${tran.id}"},
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
				url : "workbench/transaction/updateRemark.do",
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

		showRemarkList();
		showHistoryList();
	});
	
	function showHistoryList(){
		//清空历史表格数据
		$("#historyBody").empty();
		$.ajax({
			url : "workbench/transaction/getHistoryListByTranId.do",
			data : {"tranId" : "${tran.id}"},
			dataType : "json",
			success : function(data){
				if(data.success){
					$.each(data.dataList,function (i,n) {
						$("#historyBody").append(
								'<tr>' +
								'<td>'+n.stage+'</td>' +
								'<td>'+n.money+'</td>' +
								'<td>'+json[n.stage]+'</td>' +
								'<td>'+n.expectedDate+'</td>' +
								'<td>'+n.createTime+'</td>' +
								'<td>'+n.createBy+'</td>' +
								'</tr>'
						)
					})
				}
			}
		})
	}

	function showRemarkList() {
		$.ajax({
			url : "workbench/transaction/getTranRemarkById.do",
			data : {"tranId": "${tran.id}"},
			dataType : "json",
			success : function(data){

				//清空备注框
				$("#showRemarkBody").empty();
				var tname = '${tran.customerId}'+"-"+' ${tran.name}';
				$.each(data,function (i,n) {

					$("#showRemarkBody").append(
							'<div class="remarkDiv" style="height: 60px;">\n' +
							'<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">\n' +
							'<div style="position: relative; top: -40px; left: 40px;" >\n' +
							'<h5 id="content'+n.id+'">'+n.noteContent+'</h5>\n' +
							'<font color="gray">交易</font> <font color="gray">-</font> <b>'+tname+'</b> <small style="color: gray;" id="small"> '+(n.editFlag==0? n.createTime : n.editTime)+' 由 '+(n.editFlag==0? n.createBy : n.editBy)+'</small>\n' +
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
				url : "workbench/transaction/deleteRemark.do",
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

	//改变交易阶段, 参数:stage:需要改变的阶段, i:需要改变的阶段对应的下标
	function changeStage(stage,i){
		$.ajax({
			url : "workbench/transaction/changeStage.do",
			data : {
				"id" : "${tran.id}",
				"stage" : stage,
				"money" : "${tran.money}",		//生成交易历史用
				"expectedDate" : "${tran.expectedDate}" //生成交易历史用
			},
			type : "post",
			dataType : "json",
			success : function(data){
				if (data.success){
					//改变阶段成功后, 需要在详细信息页上局部刷新,要刷新阶段,可能性,修改人,修改时间
					$("#stage").html(data.tran.stage);
					$("#editBy").html(data.tran.editBy);
					$("#editTime").html(data.tran.editTime);
					var stage = $("#stage").html();
					$("#possibility").html(json[stage]);
					//调用函数改变阶段图标
					changeIcon(stage,i);
					//刷新历史
					showHistoryList();

				}else {
					alert("改变阶段失败");
				}
			}
		})

	}

	function changeIcon(stage, index1){
		//当前阶段
		var currentStage = stage;
		//当前阶段可能性
		var currentPossibility = $("#possibility").html();
		//当前阶段的下标
		var index = index1;
		//前面正常阶段和后面丢失阶段的分界点下标
		var point = "<%=point%>";

		//如果当前阶段的可能性为0, 前7个一定时黑圈,后两个一定是红叉,一个是黑叉
		if(currentPossibility=="0"){
			//遍历前7个
			for(var i=0; i<point; i++){
				//输出黑圈
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				$("#"+i).css("color","#000000");
			}
			//遍历后两个
			for(var i=point; i<"<%=dvList.size()%>"; i++){
				//如果时当前阶段
				if(i == index){
					//输出红叉
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#FF0000");
				}else {
					//输出黑叉
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#000000");
				}
			}
		}else{
			//如果当前阶段的可能性不为0, 前7个绿圈/绿色标记/黑圈, 后两个一定是黑叉
			//遍历前7个
			for(var i=0; i<point; i++){
				if(i==index){
					//如果是当前阶段输出绿色标记
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					$("#"+i).css("color","#90F790");
				}else if(i<index) {
					//如果小于当前阶段输出绿圈
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
					$("#"+i).css("color","#90F790");
				}else {
					//如果大于当前阶段输出黑圈
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					$("#"+i).css("color","#000000");
				}
			}
			//遍历后两个
			for(var i=point; i<"<%=dvList.size()%>"; i++){
				//输出黑叉
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-remove mystage");
				$("#"+i).css("color","#FF0000");
			}
		}
	}
	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${tran.customerId}-${tran.name} <small>￥${tran.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
			//准备当前阶段
			Tran tran = (Tran)request.getAttribute("tran");
			String currentStage = tran.getStage();
			//准备当前阶段的可能性
			String currentStagePossibility = pMap.get(currentStage);

			//判断当前阶段
			//如果当前阶段可能性为0, 则前7个一定是黑圈,后两个一个是红叉,一个是黑叉
			if("0".equals(currentStagePossibility)){
				for (int i=0; i<dvList.size(); i++){
					//取得每一个遍历出来的阶段,根据每一个遍历出来的阶段取其可能性
					DicValue dv = dvList.get(i);
					String listStage = dv.getValue();
					String listPossibility = pMap.get(listStage);
					//如果遍历出来的阶段可能性为0,则说明是后两个,一个是红叉,一个是黑叉
					if("0".equals(listPossibility)){
						if (listStage.equals(currentStage)){
							//如果是当前阶段输出红叉
				%>
							<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
								  class="glyphicon glyphicon-remove mystage"
								  data-toggle="popover" data-placement="bottom"
								  data-content="<%=dv.getText()%>" style="color: #FF0000;"></span>
							-----------
				<%

						}else{
							//如果不是当前阶段输出黑叉
				%>
							<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
								  class="glyphicon glyphicon-remove mystage"
								  data-toggle="popover" data-placement="bottom"
								  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
							-----------
				<%
						}

					}else{
						//如果遍历出来的阶段的可能性不为0,说明是前7个,一定是黑圈
				%>
						<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
							  class="glyphicon glyphicon-record mystage"
							  data-toggle="popover" data-placement="bottom"
							  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
						-----------
				<%
					}
				}
			}else{
				//如果当前阶段的可能性不为0,则前7个可能性是绿圈\绿色标记\黑圈, 后两个一定是黑叉
				//准备当前阶段的下标
				int index = 0;
				for (int i=0; i<dvList.size(); i++){
					DicValue dv = dvList.get(i);
					String stage = dv.getValue();
					//String possibility = pMap.get(stage);
					//如果遍历出来的阶段是当前的阶段
					if(stage.equals(currentStage)){
						index = i;
						break;
					}
				}
				for (int i=0; i<dvList.size(); i++) {
					//取得每一个遍历出来的阶段,根据每一个遍历出来的阶段取其可能性
					DicValue dv = dvList.get(i);
					String listStage = dv.getValue();
					String listPossibility = pMap.get(listStage);

					if("0".equals(listPossibility)){
						//如果遍历出来的阶段可能性为0,则说明是后两个阶段输出黑叉
				%>
						<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
							  class="glyphicon glyphicon-remove mystage"
							  data-toggle="popover" data-placement="bottom"
							  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
						-----------
				<%
					}else{
						//如果可能性不为0,则说明是前7个,可能性是绿圈\绿色标记\黑圈
						if(i == index){
							//如果是当前阶段输出绿色标记
				%>
							<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
								  class="glyphicon glyphicon-map-marker mystage"
								  data-toggle="popover" data-placement="bottom"
								  data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
							-----------
				<%
						}else if(i < index){
							//如果是小于当前阶段输出绿圈
				%>
							<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
								  class="glyphicon glyphicon-ok-circle mystage"
								  data-toggle="popover" data-placement="bottom"
								  data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
							-----------
				<%
						}else{
							//如果大于当前阶段输出黑圈
				%>
							<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
								  class="glyphicon glyphicon-record mystage"
								  data-toggle="popover" data-placement="bottom"
								  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
							-----------
				<%
						}
					}
				}

			}
		%>
		<%--<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>--%>
		<span class="closingDate">${tran.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}-${tran.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${tran.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${pMap.get(tran.stage)}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${tran.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${tran.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${tran.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${tran.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${tran.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${tran.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${tran.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${tran.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;" id="remarkBody" >
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

	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="historyBody">
						<!--ajax塞入数据-->
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>