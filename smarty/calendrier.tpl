{include file="head.tpl" titre_page="Calendrier des sorties"}
{literal}
<style>
	.sortie {
		font-size: 13px;
		padding: 3px;
		margin: 3px;
	}

	.s1, .s1 a {
		background-color: white;
		color: black;
	}

	.s2, .s2 a {
		background-color: black;
		color: white;
	}

	.s3, .s3 a {
		background-color: #12ae12;
		color: black;
	}

	.s4, .s4 a {
		background-color: black;
		color: red;
	}

	.a_moi {
		border-style: dotted;
		border-width: 2px;
		border-color: #888;
	}
</style>
{/literal}
du {$date_deb|date_format:"%d/%m/%Y"} au {$date_fin|date_format:"%d/%m/%Y"}
<a href="{$url_prev}">précédent</a> - <a href="{$url_suiv}">suivant</a><br/>
<table width="100%">
<tr>
	<th width="14%">lundi</th>
	<th width="14%">mardi</th>
	<th width="14%">mercredi</th>
	<th width="14%">jeudi</th>
	<th width="14%">vendredi</th>
	<th width="14%">samedi</th>
	<th width="14%">dimanche</th>
</tr>
{assign var=pos value=0}
{foreach from=$dates item=date}
	{if $pos eq 0} <tr> {/if}
		<td valign="top">
		{if $date}
			{$date.date|date_format:"%d"}<br/>
			{if $date.sorties|@count > 0}
				{foreach from=$date.sorties item=sd}
					{assign var=s value=$sd->sortie}
						<div class="sortie s{$sd->etat} {if $s->id_utilisateur_propose eq $id_utilisateur}a_moi{/if}">
							<a href="?t=editer&sortie={$sd->id_sortie}"><b>{$sd->date_sortie|date_format:"%H:%M"}</b>  {$sd->sortie}</a>
						</div>
				{/foreach}
			{else}
				<small>aucune sortie</small>
			{/if}
		{/if}
		</td>
	{if $pos eq 6} </tr> {/if}

	{assign var=pos value=$pos+1}
	{if $pos eq 7}{assign var=pos value=0} {/if}
{/foreach}
</table>

<span class="s1">proposition</span>
<span class="s2">non retenue</span>
<span class="s3">validée</span>
<span class="s4">annulée</span>

{include file="foot.tpl"}
