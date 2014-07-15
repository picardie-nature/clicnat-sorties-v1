{$dates|@count} activités
{if $commune} sur la commune de {$commune}{/if}
{foreach from=$dates item=date}
	{if $date->etat > 2}
	{assign var=sortie value=$date->sortie}
	{$sortie->date_sortie}
	<div class="panel panel-default panel-cal-pole{$sortie->id_sortie_pole}">
		<div class="panel-heading"> 
			{if $date->etat eq 4}
				<span class="label label-danger pull-right">Sortie annulée</span>
			{/if}
			{$sortie} 
		</div>
		<div class="panel-body">
			<p>{$sortie->description|markdown}</p>
			<a class="btn btn-default" href="?page=sortie_detail&id_sortie={$sortie->id_sortie}&date={$date->date_sortie|urlencode}">Plus d'informations sur cette activitée</a>
		</div>
		<div class="panel-footer">
			{$date->date_sortie|date_format:"%A %e %B à %Hh%M"}
			{assign var=point value=$sortie->point()}
			{assign var=commune value=$point->get_commune()}
			{if $commune}
				<div class="btn-group pull-right">
					<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
						{$commune} <span class="caret"></span>
					</button>
					<ul class="dropdown-menu" role="menu">
						<li><a href="http://obs.picardie-nature.org/?page=commune&id={$commune->id_espace}">Fiche Clicnat de la commune</a></li>
						<li><a href="?rubrique57&id_commune={$commune->id_espace}">Toutes les activités sur cette commune</a></li>
					</ul>
				</div>
			{/if}
			<div class="clearfix"></div>
		</div>
	</div>
	{/if}
{/foreach}
