<%@ include file="header.jsp" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%

    long lid = request.getParameter("licenseId") == null ? -1 : Long.parseLong((String) request.getParameter("licenseId"));
    String ciid = (String) request.getParameter("contentItemId");

    String dbUrl2 = "jdbc:oracle:thin:@//AUS-LNDSSDBP-03.wiley.com:1593/DSSPRD";
    Connection conn2 = DriverManager.getConnection(dbUrl2, "DSS", "DSS");
    PreparedStatement preparedStatement2 = conn2.prepareStatement(
            "SELECT pi.id, pi.loaderKey, pi.remoteName, pi.packageSize, pi.contentItemId, l.id as \"lid\", l.name, pi.stateCode, pi.modifiedDateTime, df.id as \"dfid\" " +
                    "FROM Push_Item pi, License l, Delivery_Format df " +
                    "WHERE df.id=l.deliveryFormatId AND pi.licenseId=l.id AND l.id=? AND pi.contentItemId=? " +
                    "ORDER BY modifiedDateTime");
    preparedStatement2.setLong(1, lid);
    preparedStatement2.setString(2, ciid);
    ResultSet result2 = preparedStatement2.executeQuery();

%>

<table width="100%" height="100%">
    <tr>
        <td valign="top" width="50%" bgcolor="#add8e6">
            <h1>Production Content</h1>
            <iframe  type="application/xml" width="100%" height="100%" src="http://dss.wiley.com:8080/resteasy/id/<%=ciid%>/metadata"/>
        </td>
        <td>&nbsp;</td>
        <td valign="top" width="50%" bgcolor="#90ee90">
            <h1>Pre-Production Content</h1>
            <iframe  type="application/xml" width="100%" height="100%" src="http://aus-lndssapp-02.wiley.com:8080/resteasy/id/<%=ciid%>/metadata"/>
        </td>
    </tr>
</table>

<%@ include file="footer.jsp" %>