{include file="head.tpl" titre_page="Edition d'une sortie" usemap=true}
<h1>Édition fiche activité : <span style="font-style:italic;">{$sortie->nom}</span></h1>
<small>Fiche créée le {$sortie->date_proposition|date_format:"%d-%m-%Y"} par {$sortie->utilisateur_propose()}</small>
<a href="?t=editer&sortie={$sortie->id_sortie}">Revenir sur la fiche de présentation</a>

<fieldset><legend>Contrôles</legend>
	{assign var="c_bloquant" value=0}
	{foreach from=$sortie->tests() item=t}
		{if $t.bloquant} {assign var="c_bloquant" value=$c_bloquant+1} {/if}
		<div class="erreur">{$t.msg}</div>
	{foreachelse}
		Votre formulaire est correctement rempli.
	{/foreach}
</fieldset>


<fieldset><legend>Dates</legend>
{if $c_bloquant == 0} 
	{if $edit}
		<form method="post" action="?t=editer&sortie={$sortie->id_sortie}&ajouter_date=1">
			Sélection d'une date pour votre activité : <span style="font-style:italic;">{$sortie->nom}</span> <input type="text" name="date" size="10" id="nouvelle_date"/><input type="submit" value="Ajouter"/>
		</form>
	{/if}
	{foreach from=$sortie->dates() item=date}
		<div style="width:40%; float:left; background-color:#c1b9aa; padding:4px; margin:8px; box-shadow: -1px 2px 5px 1px rgba(0, 0, 0, 0.7); ">
			{include file="editer_date.tpl" date=$date}
		</div>
		<!-- <li><a href="?t=editer_date&date={$date->date_sortie|date_format:"%s"}&id_sortie={$date->id_sortie}">{$date->date_sortie|date_format:"%d-%m-%Y %H:%M"}</a> {$date->etat_lib}</li> -->
	{foreachelse}
		Pas de date, vous devez en proposer.
	{/foreach}
	<div style="clear:both;"></div>
	<p>Pour proposer votre activité une seconde fois à l'identique (même lieu, même contenu) à une autre date / horaire, comme pour la première date, recréer une nouvelle en utilisant le bouton ajouter.</p>
	<script>J('#nouvelle_date').datepicker();</script>
{else}
	Vous devez corriger les {$c_bloquant} erreur(s) du cadre ci-dessous <a href="?t=editer&sortie={$sortie->id_sortie}">en retournant sur la fiche</a>.
{/if}
</fieldset>
{include file="foot.tpl"}
