{include file="head.tpl" titre_page="Suivi des modifications"}
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

                <div style="width:400px; float:left; padding: 4px;">
                        <h1>En attente</h1>
                        {foreach from=$en_attente item=sortie}
                                <div class="item_sortie s1">
                                        <a href="?t=editer&sortie={$sortie.id_sortie}">{if strlen($sortie.nom) eq 0}sortie sans nom{else}{$sortie.nom}{/if}</a> le 
                                        <a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
                                </div>
                        {/foreach}
                </div>

                <div style="width:400px; float:left; padding: 4px;">
                        <h1>Derni&egrave;res modifications</h1>
                        {foreach from=$dernieres_modifs item=sortie}
                                <div class="item_sortie s{$sortie.etat}">
					{$sortie.date_maj} | 
                                        <a href="?t=editer&sortie={$sortie.id_sortie}">{if strlen($sortie.nom) eq 0}sortie sans nom{else}{$sortie.nom}{/if}</a> le 
                                        <a href="?t=editer_suiv&id_sortie={$sortie.id_sortie}">{$sortie.date_sortie|date_format:"%d-%m-%Y"}</a>
                                </div>
                        {/foreach}
                </div>

<p style="clear:both;" />

<p>
<span class="s1">proposition</span>
<span class="s2">non retenue</span>
<span class="s3">validée</span>
<span class="s4">annulée</span>
</p>

{include file="foot.tpl"}
