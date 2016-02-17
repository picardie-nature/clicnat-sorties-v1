{include file="head.tpl" titre_page="Selectionner la periode d'export" usemap=true}

{literal}
<script>
function set_form_date(d_j, d_m, d_a, f_j, f_m, f_a) {
	jQuery('#seldj').val(d_j);
	jQuery('#seldm').val(d_m);
	jQuery('#selda').val(d_a);
	jQuery('#selfj').val(f_j);
	jQuery('#selfm').val(f_m);
	jQuery('#selfa').val(f_a);
	return false;
}
function sel_all_types() {
	jQuery('[id^=type-]').attr('checked', true);
	return false;
}
</script>
{/literal}

<h1>Selectionner la periode</h1>
<form method="post" action="?t=xml">

<fieldset><legend>Periode</legend>
<span class="field-name">Debut&nbsp;:&nbsp;</span>
<span class="field-content">
<select name="d_j" id="seldj">
{section name=list_j start=1 loop=32 step=1}
<option value="{$smarty.section.list_j.index}">{$smarty.section.list_j.index}</option>
{/section}
</select>
<select name="d_m" id="seldm">
<option  value="1">Janvier</option>
<option  value="2">Fevrier</option>
<option  value="3">Mars</option>
<option  value="4">Avril</option>
<option  value="5">Mai</option>
<option  value="6">Juin</option>
<option  value="7">Juillet</option>
<option  value="8">Aout</option>
<option  value="9">Septembre</option>
<option value="10">Octobre</option>
<option value="11">Novembre</option>
<option value="12">Decembre</option>
</select>
<select name="d_a" id="selda">
<option value="2012">2012</option>
<option value="2013">2013</option>
<option value="2014">2014</option>
<option value="2015">2015</option>
<option value="2016">2016</option>
<option value="2017">2017</option>
<option value="2018">2018</option>
</select>
</span>
	<br/>
<span class="field-name">Fin&nbsp;:&nbsp;</span>
<span class="field-content">
<select name="f_j" id="selfj">
{section name=list_j start=1 loop=32 step=1}
<option value="{$smarty.section.list_j.index}">{$smarty.section.list_j.index}</option>
{/section}
</select>
<select name="f_m" id="selfm">
	<option  value="1">Janvier</option>
	<option  value="2">Fevrier</option>
	<option  value="3">Mars</option>
	<option  value="4">Avril</option>
	<option  value="5">Mai</option>
	<option  value="6">Juin</option>
	<option  value="7">Juillet</option>
	<option  value="8">Aout</option>
	<option  value="9">Septembre</option>
	<option value="10">Octobre</option>
	<option value="11">Novembre</option>
	<option value="12">Decembre</option>
</select>
<select name="f_a" id="selfa">
	<option value="2012">2012</option>
	<option value="2013">2013</option>
	<option value="2014">2014</option>
	<option value="2015">2015</option>
	<option value="2016">2016</option>
	<option value="2017">2017</option>
</select>
</span>
	<br/>

<span class="field-name">&Eacute;tats&nbsp;:&nbsp;</span>
<span class="field-content">
<input type="checkbox" class="check-with-label" name="etats[]" id="etat-prop" value="1">
<label class="label-for-check" for="etat-prop">proposition</label>
<input type="checkbox" class="check-with-label" name="etats[]" id="etat-non" value="2">
<label class="label-for-check" for="etat-non">non retenue</label>
<input type="checkbox" class="check-with-label" name="etats[]" id="etat-annul" value="4">
<label class="label-for-check" for="etat-annul">annul&eacute;e</label>
<input type="checkbox" class="check-with-label" name="etats[]" id="etat-valid" value="3" checked="checked">
<label class="label-for-check" for="etat-valid">valid&eacute;e</label>
</span>
<br/>

<span class="field-name">Types&nbsp;:&nbsp;</span>
<span class="field-content">
{foreach from=$sorties_types item=st}
<nobr>
<input type="checkbox" class="check-with-label" name="types[]" id="type-{$st.id_sortie_type}" value="{$st.id_sortie_type}">
<label class="label-for-check" for="type-{$st.id_sortie_type}">{$st.lib|replace:" ":"&nbsp;"}</label>&nbsp;
</nobr>
{/foreach}

<br />
<a href="#" onClick="return sel_all_types();">s&eacute;lectionner tous</a>
</span>
<br/>

<span class="field-name">Pays&nbsp;&nbsp;</span>
<select name="pays">
	<option value="">Tous</option>
{foreach from=$liste_pays item=pays}
	<option value="{$pays->id_pays}">{$pays}</option>
{/foreach}
</select>
</fieldset>
<fieldset>
	Format du fichier : 
	<select name="format">
		<option value="xml">XML</option>
		<option value="csv">CSV</option>
	</select>
</fieldset>
<div style="text-align:right;">
	<input type="submit" value="Exporter">
</div>
</form>
{include file="foot.tpl"}
