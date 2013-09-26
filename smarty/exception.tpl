{include file="head.tpl" titre_page="Erreur"}
<h1>Erreur de l'application</h1>
Message : <b>{$ex->getMessage()}</b>
<pre>{$msg}</pre>
{include file="foot.tpl"}
